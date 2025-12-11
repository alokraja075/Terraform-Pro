output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for s in aws_subnet.private : s.id]
}

output "nat_gateway_ids" {
  description = "List of NAT gateway IDs (empty if not created)"
  value       = var.nat_gateway_strategy == "none" ? [] : [for n in aws_nat_gateway.nat : n.id]
}

output "flow_log_id" {
  description = "Flow Log ID (if created)"
  value       = length(aws_flow_log.this) > 0 ? aws_flow_log.this[0].id : ""
}

output "s3_endpoint_id" {
  description = "S3 VPC endpoint ID (if created)"
  value       = length(aws_vpc_endpoint.s3) > 0 ? aws_vpc_endpoint.s3[0].id : ""
}

output "dynamodb_endpoint_id" {
  description = "DynamoDB VPC endpoint ID (if created)"
  value       = length(aws_vpc_endpoint.dynamodb) > 0 ? aws_vpc_endpoint.dynamodb[0].id : ""
}

output "public_network_acl_id" {
  description = "Public network ACL id (if created)"
  value       = length(aws_network_acl.public) > 0 ? aws_network_acl.public[0].id : ""
}

output "private_network_acl_id" {
  description = "Private network ACL id (if created)"
  value       = length(aws_network_acl.private) > 0 ? aws_network_acl.private[0].id : ""
}
