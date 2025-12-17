locals {
  key_dir = "${path.module}/keys"
}

locals {
  alb_short_id = element(split("/", aws_lb.application_lb.arn), length(split("/", aws_lb.application_lb.arn)) - 1)
  tg_short_id  = element(split("/", aws_lb_target_group.app_tg.arn), length(split("/", aws_lb_target_group.app_tg.arn)) - 1)
}

# Create keys folder if not present
resource "null_resource" "create_key_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ${local.key_dir}"
  }
}

# Generate SSH key pair (private + public)
resource "null_resource" "generate_ssh_key" {
  depends_on = [null_resource.create_key_dir]

  provisioner "local-exec" {
    command = <<-EOF
      if [ ! -f "${local.key_dir}/${var.key_pair_name}" ]; then
        ssh-keygen -t rsa -b 4096 -f "${local.key_dir}/${var.key_pair_name}" -N ''
        chmod 400 "${local.key_dir}/${var.key_pair_name}"
      fi
    EOF
  }
}

# Read public key
data "local_file" "public_key" {
  depends_on = [null_resource.generate_ssh_key]
  filename   = "${local.key_dir}/${var.key_pair_name}.pub"
}

# Create AWS Key Pair using generated key
resource "aws_key_pair" "ec2_key" {
  depends_on = [null_resource.generate_ssh_key]

  key_name   = var.key_pair_name
  public_key = data.local_file.public_key.content
}

# Security Group
resource "aws_security_group" "sg" {
  name        = "${var.name}-sg"
  description = "Allow SSH and HTTP"

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "ec2template" {
  name   = "${var.name}-launch-template"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.ec2_key.key_name

  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = base64encode(var.user_data)

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 10
      volume_type = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name}-web"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "ec2_asg" {
  launch_template {
    id      = aws_launch_template.ec2template.id
    version = "$Latest"
  }
  name                = "${var.name}-asg"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.name}-web"
    propagate_at_launch = true
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 75
      instance_warmup       = 300
    }
    triggers = ["launch_template"]
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_policy" "alb_request_target_tracking" {
  name                   = "${var.name}-alb-request-tracking"
  autoscaling_group_name = aws_autoscaling_group.ec2_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label = "app/${aws_lb.application_lb.name}/${local.alb_short_id}/targetgroup/${aws_lb_target_group.app_tg.name}/${local.tg_short_id}"
    }
    target_value = 1.0
  }
}




resource "aws_lb" "application_lb" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = var.subnet_ids
  tags = {
    Name = "${var.name}-alb"
  } 
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
resource "aws_autoscaling_attachment" "asg_tg_attach" {
  autoscaling_group_name = aws_autoscaling_group.ec2_asg.name
  lb_target_group_arn    = aws_lb_target_group.app_tg.arn
}

/* Trigger a rolling replacement whenever a new launch template version is created. */
/* aws_autoscaling_instance_refresh not supported in this provider version, managed via `instance_refresh` in the ASG block and optional local fallback below. */

/* As a fallback for environments where `aws_autoscaling_instance_refresh` is not available, provide an optional local refresh trigger
   executed by the machine running Terraform using the AWS CLI. This will run only when the launch template latest_version changes.
   Note: this requires the AWS CLI and credentials to be configured on the machine running `terraform apply`. */
resource "null_resource" "refresh_via_cli" {
  triggers = {
    lt_version = aws_launch_template.ec2template.latest_version
  }

  provisioner "local-exec" {
    command = "aws autoscaling start-instance-refresh --auto-scaling-group-name ${aws_autoscaling_group.ec2_asg.name} --preferences MinHealthyPercentage=75,InstanceWarmup=300 --desired-configuration 'LaunchTemplate={LaunchTemplateId=${aws_launch_template.ec2template.id},Version=${aws_launch_template.ec2template.latest_version}}' || true"
  }

  depends_on = [aws_autoscaling_group.ec2_asg]
}


# # EC2 Instance
# resource "aws_instance" "web" {
#   ami                    = var.ami
#   instance_type          = var.instance_type
#   key_name               = aws_key_pair.ec2_key.key_name
#   vpc_security_group_ids = [aws_security_group.sg.id]

#   user_data = var.user_data

#   root_block_device {
#     volume_size = 10
#     volume_type = "gp3"
#   }

#   tags = {
#     Name = "${var.name}-web"
#   }
# }