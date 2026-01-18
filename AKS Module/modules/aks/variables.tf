variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure location where resources will be created"
  type        = string
  default     = "East US"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the AKS cluster"
  type        = string
  default     = "1.28"
}

variable "sku_tier" {
  description = "The SKU Tier for the AKS cluster (Free, Standard, Premium)"
  type        = string
  default     = "Standard"
}

# Default Node Pool Variables
variable "default_node_pool_name" {
  description = "Name of the default node pool"
  type        = string
  default     = "default"
}

variable "default_node_pool_vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "default_node_pool_node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 3
}

variable "default_node_pool_min_count" {
  description = "Minimum number of nodes for auto-scaling"
  type        = number
  default     = 1
}

variable "default_node_pool_max_count" {
  description = "Maximum number of nodes for auto-scaling"
  type        = number
  default     = 5
}

variable "enable_auto_scaling" {
  description = "Enable auto-scaling for the default node pool"
  type        = bool
  default     = true
}

variable "default_node_pool_os_disk_size_gb" {
  description = "OS disk size in GB for nodes"
  type        = number
  default     = 30
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["1", "2", "3"]
}

# Network Variables
variable "vnet_subnet_id" {
  description = "Subnet ID for the AKS cluster"
  type        = string
}

variable "network_plugin" {
  description = "Network plugin to use (azure or kubenet)"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy to use (azure or calico)"
  type        = string
  default     = "azure"
}

variable "dns_service_ip" {
  description = "DNS service IP address"
  type        = string
  default     = "10.2.0.10"
}

variable "service_cidr" {
  description = "Service CIDR"
  type        = string
  default     = "10.2.0.0/24"
}

variable "load_balancer_sku" {
  description = "Load balancer SKU (basic or standard)"
  type        = string
  default     = "standard"
}

# Azure AD Integration
variable "enable_azure_ad_integration" {
  description = "Enable Azure AD integration for RBAC"
  type        = bool
  default     = true
}

variable "azure_ad_admin_group_object_ids" {
  description = "List of Azure AD group object IDs that will be cluster admins"
  type        = list(string)
  default     = []
}

variable "azure_rbac_enabled" {
  description = "Enable Azure RBAC for Kubernetes authorization"
  type        = bool
  default     = true
}

# Monitoring and Logging
variable "enable_log_analytics" {
  description = "Enable Log Analytics integration"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_sku" {
  description = "SKU for Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "Log retention in days"
  type        = number
  default     = 30
}

variable "enable_microsoft_defender" {
  description = "Enable Microsoft Defender for Containers"
  type        = bool
  default     = false
}

# Key Vault Secrets Provider
variable "enable_key_vault_secrets_provider" {
  description = "Enable Key Vault Secrets Provider"
  type        = bool
  default     = false
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
  description = "Enable HTTP Application Routing"
  type        = bool
  default     = false
}

variable "enable_private_cluster" {
  description = "Enable private cluster"
  type        = bool
  default     = false
}

# Azure Container Registry
variable "create_acr" {
  description = "Create Azure Container Registry"
  type        = bool
  default     = false
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = ""
}

variable "acr_sku" {
  description = "SKU for Azure Container Registry"
  type        = string
  default     = "Standard"
}

variable "acr_admin_enabled" {
  description = "Enable admin user for ACR"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
