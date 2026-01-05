output "node_group_id" {
  description = "EKS node group ID"
  value       = aws_eks_node_group.main.id
}

output "node_group_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
  value       = aws_eks_node_group.main.arn
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = aws_eks_node_group.main.status
}

output "node_group_role_arn" {
  description = "IAM role ARN of the EKS node group"
  value       = aws_iam_role.eks_node_group_role.arn
}

output "node_security_group_id" {
  description = "Security group ID of the node group"
  value       = try(aws_security_group.eks_node_sg[0].id, null)
}
