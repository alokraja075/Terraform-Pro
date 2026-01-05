variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "subnet_ids" {
  description = "List of subnet IDs to launch the cluster in"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the EKS cluster"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID where the cluster and nodes will be deployed"
  type        = string
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

variable "create_security_group" {
  description = "Whether to create a security group for the cluster"
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
  default     = 30
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts (IRSA)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default     = {}
}
