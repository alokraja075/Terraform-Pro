output "launch_template_id" {
	value = aws_launch_template.ec2template.id
}

output "asg_name" {
	description = "Auto Scaling Group name"
	value       = aws_autoscaling_group.ec2_asg.name
}

output "lb_dns_name" {
	description = "Load balancer DNS name"
	value       = aws_lb.application_lb.dns_name
}

output "target_group_arn" {
	description = "Application LB Target Group ARN"
	value       = aws_lb_target_group.app_tg.arn
}

output "private_key_path" {
	value = "${path.module}/keys/${var.key_pair_name}"
}

output "public_key_path" {
	value = "${path.module}/keys/${var.key_pair_name}.pub"
}

output "key_name" {
	value = aws_key_pair.ec2_key.key_name
}
