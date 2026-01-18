variable "node_pool_name" {
  description = "Name of the node pool"
  type        = string
}

variable "cluster_id" {
  description = "The ID of the AKS cluster"
  type        = string
}

variable "vm_size" {
  description = "VM size for the node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "node_count" {
  description = "Number of nodes in the node pool"
  type        = number
  default     = 3
}

variable "min_count" {
  description = "Minimum number of nodes for auto-scaling"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum number of nodes for auto-scaling"
  type        = number
  default     = 5
}

variable "enable_auto_scaling" {
  description = "Enable auto-scaling for the node pool"
  type        = bool
  default     = true
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 30
}

variable "os_type" {
  description = "OS type (Linux or Windows)"
  type        = string
  default     = "Linux"
}

variable "mode" {
  description = "Mode of the node pool (System or User)"
  type        = string
  default     = "User"
}

variable "vnet_subnet_id" {
  description = "Subnet ID for the node pool"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "max_pods" {
  description = "Maximum number of pods per node"
  type        = number
  default     = 30
}

variable "os_disk_type" {
  description = "OS disk type (Managed or Ephemeral)"
  type        = string
  default     = "Managed"
}

variable "priority" {
  description = "Priority of the node pool (Regular or Spot)"
  type        = string
  default     = "Regular"
}

variable "eviction_policy" {
  description = "Eviction policy for spot instances (Deallocate or Delete)"
  type        = string
  default     = "Delete"
}

variable "spot_max_price" {
  description = "Maximum price for spot instances (-1 for on-demand price)"
  type        = number
  default     = -1
}

variable "max_surge" {
  description = "Maximum surge during node pool upgrade"
  type        = string
  default     = "10%"
}

variable "node_labels" {
  description = "Labels to apply to nodes"
  type        = map(string)
  default     = null
}

variable "node_taints" {
  description = "Taints to apply to nodes"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the node pool"
  type        = map(string)
  default     = {}
}
