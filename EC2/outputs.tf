output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "ec2_ssh_command" {
  description = "SSH command to connect (uses generated key if create_key = true)"
  value       = var.create_key ? "ssh -i ${var.private_key_path} ec2-user@${aws_instance.web.public_ip}" : "ssh -i <path-to-your-key> ec2-user@${aws_instance.web.public_ip}"
}

output "web_url" {
  description = "URL to access the web application"
  value       = "http://${aws_instance.web.public_ip}:8000"
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.web_sg.id
}