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

# Example: Use for_each to create multiple security groups
resource "aws_security_group" "sg" {
  for_each    = var.security_groups
  name        = "${each.key}-sg"
  description = each.value.description

  dynamic "ingress" {
    for_each = each.value.ingress_ports
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

# Example: Use for_each to create multiple launch templates
resource "aws_launch_template" "ec2template" {
  for_each      = var.launch_templates
  name          = "${each.key}-launch-template"
  image_id      = each.value.ami
  instance_type = each.value.instance_type
  key_name      = aws_key_pair.ec2_key.key_name
  vpc_security_group_ids = [aws_security_group.sg[each.value.sg_key].id]
  user_data     = base64encode(each.value.user_data)

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
      Name = "${each.key}-web"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}
# Example: Use for_each to create multiple autoscaling groups
resource "aws_autoscaling_group" "ec2_asg" {
  for_each = var.autoscaling_groups
  launch_template {
    id      = aws_launch_template.ec2template[each.value.lt_key].id
    version = "$Latest"
  }
  name                = "${each.value.name}-asg"
  min_size            = each.value.min_size
  max_size            = each.value.max_size
  desired_capacity    = each.value.desired_capacity
  vpc_zone_identifier = each.value.subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${each.value.name}-web"
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
    security_groups    = [for sg in aws_security_group.sg : sg.id]
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
  for_each = aws_autoscaling_group.ec2_asg
  autoscaling_group_name = each.value.name
  lb_target_group_arn    = aws_lb_target_group.app_tg.arn
}

/* Trigger a rolling replacement whenever a new launch template version is created. */
/* aws_autoscaling_instance_refresh not supported in this provider version, managed via `instance_refresh` in the ASG block and optional local fallback below. */

/* As a fallback for environments where `aws_autoscaling_instance_refresh` is not available, provide an optional local refresh trigger
   executed by the machine running Terraform using the AWS CLI. This will run only when the launch template latest_version changes.
   Note: this requires the AWS CLI and credentials to be configured on the machine running `terraform apply`. */
resource "null_resource" "refresh_via_cli" {
  for_each = aws_autoscaling_group.ec2_asg
  triggers = {
    lt_version = aws_launch_template.ec2template[each.key].latest_version
  }

  provisioner "local-exec" {
    command = "aws autoscaling start-instance-refresh --auto-scaling-group-name ${each.value.name} --preferences MinHealthyPercentage=75,InstanceWarmup=300 --desired-configuration 'LaunchTemplate={LaunchTemplateId=${aws_launch_template.ec2template[each.key].id},Version=${aws_launch_template.ec2template[each.key].latest_version}}' || true"
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
