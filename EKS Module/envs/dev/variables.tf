variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "eks-dev"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-dev-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "VPC ID where the cluster and nodes will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to launch the cluster in"
  type        = list(string)
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
  default     = "eks-dev-node-group"
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "instance_types" {
  description = "List of instance types for the node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "disk_size" {
  description = "Disk size in GiB for worker nodes"
  type        = number
  default     = 30
}

variable "node_labels" {
  description = "Key-value map of Kubernetes labels for nodes"
  type        = map(string)
  default = {
    Environment = "dev"
  }
}

variable "enabled_cluster_log_types" {
  description = "List of log types to enable for the EKS cluster"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts (IRSA)"
  type        = bool
  default     = true
}

variable "create_cloudwatch_log_group" {
  description = "Whether to create CloudWatch log group for cluster logs"
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "Number of days to retain log events"
  type        = number
  default     = 7
}

variable "enable_ssm_access" {
  description = "Enable Systems Manager access for nodes"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    CreatedBy   = "Terraform"
  }
}
