output "ec2_publicip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web_instance.public_ip
}

output "ec2_instace_Id" {
  description = "Instance ID"
  value       = aws_instance.web_instance.id
}

output "ec2_ssh_command" {
  description = "SSH command to connect (uses generated key if create_key = true)"
  value       = "ssh -i ${path.module}/keys/${var.key_pair_name} ec2-user@${aws_instance.web_instance.public_ip}"
}

output "web_url" {
  description = "URL to access the web application"
  value       = "http://${aws_instance.web_instance.public_ip}:8000"
}