output "asg_name" {
  value = module.app_ec2.asg_name
}

output "launch_template_id" {
  value = module.app_ec2.launch_template_id
}

output "ssh_private_key_path" {
  value = module.app_ec2.private_key_path
}

output "ssh_public_key_path" {
  value = module.app_ec2.public_key_path
}
output "web_url" {
  description = "URL to access the web application"
  value       = "http://${module.app_ec2.lb_dns_name}"
}
