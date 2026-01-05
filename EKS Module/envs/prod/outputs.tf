output "cluster_id" {
  description = "The ID/name of the EKS cluster"
  value       = module.eks_cluster.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster API server"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks_cluster.cluster_arn
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = module.eks_cluster.cluster_version
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks_cluster.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks_cluster.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider (for IRSA)"
  value       = module.eks_cluster.oidc_provider_arn
}

output "node_group_id" {
  description = "EKS node group ID"
  value       = module.eks_node_group.node_group_id
}

output "node_group_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
  value       = module.eks_node_group.node_group_arn
}

output "node_group_role_arn" {
  description = "IAM role ARN of the EKS node group"
  value       = module.eks_node_group.node_group_role_arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for cluster logs"
  value       = module.eks_cluster.cloudwatch_log_group_name
}
