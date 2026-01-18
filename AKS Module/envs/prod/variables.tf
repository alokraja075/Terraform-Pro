# General Variables
variable "location" {
  description = "Azure location for resources"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "aks-prod-rg"
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "aks-prod-cluster"
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster"
  type        = string
  default     = "aks-prod"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "sku_tier" {
  description = "AKS SKU tier"
  type        = string
  default     = "Standard"
}

# Default Node Pool Variables
variable "default_node_pool_name" {
  description = "Name of the default node pool"
  type        = string
  default     = "system"
}

variable "default_node_pool_vm_size" {
  description = "VM size for default node pool"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "default_node_pool_node_count" {
  description = "Initial node count for default pool"
  type        = number
  default     = 3
}

variable "default_node_pool_min_count" {
  description = "Minimum nodes for auto-scaling"
  type        = number
  default     = 3
}

variable "default_node_pool_max_count" {
  description = "Maximum nodes for auto-scaling"
  type        = number
  default     = 6
}

variable "enable_auto_scaling" {
  description = "Enable auto-scaling"
  type        = bool
  default     = true
}

variable "default_node_pool_os_disk_size_gb" {
  description = "OS disk size for default pool"
  type        = number
  default     = 50
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["1", "2", "3"]
}

# Network Variables
variable "network_plugin" {
  description = "Network plugin"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy"
  type        = string
  default     = "azure"
}

variable "dns_service_ip" {
  description = "DNS service IP"
  type        = string
  default     = "10.2.0.10"
}

variable "service_cidr" {
  description = "Service CIDR"
  type        = string
  default     = "10.2.0.0/24"
}

variable "load_balancer_sku" {
  description = "Load balancer SKU"
  type        = string
  default     = "standard"
}

# Azure AD Integration
variable "enable_azure_ad_integration" {
  description = "Enable Azure AD integration"
  type        = bool
  default     = true
}

variable "azure_ad_admin_group_object_ids" {
  description = "Azure AD admin group IDs"
  type        = list(string)
  default     = []
}

variable "azure_rbac_enabled" {
  description = "Enable Azure RBAC"
  type        = bool
  default     = true
}

# Monitoring Variables
variable "enable_log_analytics" {
  description = "Enable Log Analytics"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_sku" {
  description = "Log Analytics workspace SKU"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "Log retention period"
  type        = number
  default     = 90
}

variable "enable_microsoft_defender" {
  description = "Enable Microsoft Defender"
  type        = bool
  default     = true
}

# Key Vault Secrets Provider
variable "enable_key_vault_secrets_provider" {
  description = "Enable Key Vault secrets provider"
  type        = bool
  default     = true
}

variable "secret_rotation_enabled" {
  description = "Enable secret rotation"
  type        = bool
  default     = true
}

variable "secret_rotation_interval" {
  description = "Secret rotation interval"
  type        = string
  default     = "2m"
}

# Other Settings
variable "enable_http_application_routing" {
  description = "Enable HTTP application routing"
  type        = bool
  default     = false
}

variable "enable_private_cluster" {
  description = "Enable private cluster"
  type        = bool
  default     = true
}

# ACR Variables
variable "create_acr" {
  description = "Create Azure Container Registry"
  type        = bool
  default     = true
}

variable "acr_name" {
  description = "ACR name"
  type        = string
  default     = "aksprodacr001"
}

variable "acr_sku" {
  description = "ACR SKU"
  type        = string
  default     = "Premium"
}

variable "acr_admin_enabled" {
  description = "Enable ACR admin"
  type        = bool
  default     = false
}

# User Node Pool Variables
variable "create_user_node_pool" {
  description = "Create additional user node pool"
  type        = bool
  default     = true
}

variable "user_node_pool_name" {
  description = "User node pool name"
  type        = string
  default     = "user"
}

variable "user_node_pool_vm_size" {
  description = "User node pool VM size"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "user_node_pool_node_count" {
  description = "User node pool node count"
  type        = number
  default     = 3
}

variable "user_node_pool_min_count" {
  description = "User node pool min count"
  type        = number
  default     = 2
}

variable "user_node_pool_max_count" {
  description = "User node pool max count"
  type        = number
  default     = 10
}

variable "user_node_pool_os_disk_size_gb" {
  description = "User node pool OS disk size"
  type        = number
  default     = 50
}

variable "user_node_pool_labels" {
  description = "User node pool labels"
  type        = map(string)
  default     = {
    "nodepool-type" = "user"
    "environment"   = "production"
    "workload-type" = "general"
  }
}

variable "user_node_pool_taints" {
  description = "User node pool taints"
  type        = list(string)
  default     = []
}

# Spot Node Pool Variables
variable "create_spot_node_pool" {
  description = "Create spot instance node pool"
  type        = bool
  default     = false
}

variable "spot_node_pool_name" {
  description = "Spot node pool name"
  type        = string
  default     = "spot"
}

variable "spot_node_pool_vm_size" {
  description = "Spot node pool VM size"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "spot_node_pool_node_count" {
  description = "Spot node pool node count"
  type        = number
  default     = 1
}

variable "spot_node_pool_min_count" {
  description = "Spot node pool min count"
  type        = number
  default     = 0
}

variable "spot_node_pool_max_count" {
  description = "Spot node pool max count"
  type        = number
  default     = 10
}

variable "spot_node_pool_os_disk_size_gb" {
  description = "Spot node pool OS disk size"
  type        = number
  default     = 50
}

variable "spot_eviction_policy" {
  description = "Spot eviction policy"
  type        = string
  default     = "Delete"
}

variable "spot_max_price" {
  description = "Spot max price (-1 for on-demand)"
  type        = number
  default     = -1
}

variable "spot_node_pool_labels" {
  description = "Spot node pool labels"
  type        = map(string)
  default     = {
    "nodepool-type" = "spot"
    "environment"   = "production"
    "workload-type" = "batch"
  }
}

variable "spot_node_pool_taints" {
  description = "Spot node pool taints"
  type        = list(string)
  default     = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]
}

# Tags
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Project     = "AKS-Prod"
  }
}
