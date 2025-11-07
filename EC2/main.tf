provider "aws" {
  region = var.region_name
}

# Generate an SSH key locally and upload the public key to AWS as an aws_key_pair
resource "tls_private_key" "ssh_key" {
  count      = var.create_key ? 1 : 0
  algorithm  = "RSA"
  rsa_bits   = 4096
}

resource "aws_key_pair" "deployer" {
  count      = var.create_key ? 1 : 0
  key_name   = var.key_name
  public_key = tls_private_key.ssh_key[0].public_key_openssh
}

# Persist the generated private key to a local file so you can SSH in
resource "local_file" "private_key" {
  count    = var.create_key ? 1 : 0
  content  = tls_private_key.ssh_key[0].private_key_pem
  filename = var.private_key_path
}

# Ensure the file has secure permissions after creation (runs locally during apply)
resource "null_resource" "fix_key_permissions" {
  count = var.create_key ? 1 : 0

  triggers = {
    file = var.private_key_path
  }

  provisioner "local-exec" {
    command = "chmod 600 ${var.private_key_path} || true"
  }
}

# Security group to allow SSH and HTTP on port 8000
resource "aws_security_group" "web_sg" {
  name        = "ec2-web-sg"
  description = "Allow SSH and HTTP(8000)"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Use Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# EC2 instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.create_key ? aws_key_pair.deployer[0].key_name : var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  # Simple user data: install python3, write an index page and start a server on port 8000
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

  tags = {
    Name = "terraform-ec2-web"
  }
}

