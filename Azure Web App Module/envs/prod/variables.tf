variable "app_name_prefix" {
  type        = string
  description = "Prefix for naming Azure resources for the prod web app."
  default     = "tf-webapp-prod"
}

variable "location" {
  type        = string
  description = "Azure region for prod (e.g., eastus)."
  default     = "eastus"
}

variable "sku_name" {
  type        = string
  description = "App Service Plan SKU name for prod (e.g., S1)."
  default     = "S1"
}

variable "node_version" {
  type        = string
  description = "Node runtime version for prod."
  default     = "18-lts"
}

variable "tags" {
  type        = map(string)
  description = "Tags for prod resources."
  default     = {
    environment = "prod"
    project     = "terraform-pro"
  }
}