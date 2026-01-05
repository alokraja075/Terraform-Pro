variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to launch nodes in"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the nodes will be deployed"
  type        = string
}

variable "cluster_security_group_ids" {
  description = "Security group IDs of the EKS cluster"
  type        = list(string)
  default     = []
}

variable "kubernetes_version" {
  description = "Kubernetes version for the node group"
  type        = string
  default     = null
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
  default     = 5
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

variable "labels" {
  description = "Key-value map of Kubernetes labels"
  type        = map(string)
  default     = {}
}

variable "create_security_group" {
  description = "Whether to create a security group for the node group"
  type        = bool
  default     = true
}

variable "enable_ssm_access" {
  description = "Enable Systems Manager access for nodes"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default     = {}
}
