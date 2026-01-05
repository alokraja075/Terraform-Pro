module "eks_cluster" {
  source = "../../modules/eks"

  cluster_name            = var.cluster_name
  kubernetes_version      = var.kubernetes_version
  subnet_ids              = var.subnet_ids
  vpc_id                  = var.vpc_id
  enabled_cluster_log_types = var.enabled_cluster_log_types
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  enable_irsa             = var.enable_irsa
  create_cloudwatch_log_group = var.create_cloudwatch_log_group
  log_retention_in_days   = var.log_retention_in_days

  tags = var.common_tags
}

module "eks_node_group" {
  source = "../../modules/eks_node_group"

  cluster_name                = module.eks_cluster.cluster_id
  node_group_name             = var.node_group_name
  subnet_ids                  = var.subnet_ids
  vpc_id                      = var.vpc_id
  kubernetes_version          = var.kubernetes_version
  desired_size                = var.desired_size
  min_size                    = var.min_size
  max_size                    = var.max_size
  instance_types              = var.instance_types
  disk_size                   = var.disk_size
  labels                      = var.node_labels
  enable_ssm_access           = var.enable_ssm_access

  tags = var.common_tags
}

# Data source to get VPC information (if not using explicit subnet/VPC)
data "aws_vpc" "main" {
  id = var.vpc_id
}
