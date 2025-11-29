provider "aws" {
  region = var.region_name
}


resource "null_resource" "generate_ssh_key" {
  provisioner "local-exec" {
    command = <<-EOF
      if [ ! -f "${path.module}/keys/${var.key_pair_name}" ]; then
        ssh-keygen -t rsa -b 4096 -f "${path.module}/keys/${var.key_pair_name}" -N ''
        chmod 400 "${path.module}/keys/${var.key_pair_name}"
      fi
    EOF
  }
}

data "local_file" "public_key" {
  depends_on = [null_resource.generate_ssh_key]
  filename   = "${path.module}/keys/${var.key_pair_name}.pub"
}

resource "aws_key_pair" "ec2_key" {
  depends_on = [null_resource.generate_ssh_key]
  key_name   = var.key_pair_name
  public_key = data.local_file.public_key.content
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow SSH and HTTP(8000)"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "Custom TCP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "HTTP app on port 8000"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allowed_cidr]
  }
  tags = {
    Name = "mysecurity"
  }
}


data "aws_ami" "ec2ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "web_instance" {
  ami                         = data.aws_ami.ec2ami.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ec2_key.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "MyEC2Instance"
  }
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              set -eux
              yum update -y
              yum install -y python3
              mkdir -p /var/www/html
              cat > /var/www/html/index.html <<'HTML'
              <html><body><h1>Terraform EC2 web server</h1><p>It works on port 8000</p></body></html>
              HTML
              nohup python3 -m http.server 8000 --directory /var/www/html >/var/log/httpserver.log 2>&1 &
              EOF
}