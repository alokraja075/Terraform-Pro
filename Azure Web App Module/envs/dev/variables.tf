variable "app_name_prefix" {
  type        = string
  description = "Prefix for naming Azure resources for the dev web app."
  default     = "tf-webapp-dev"
}

variable "location" {
  type        = string
  description = "Azure region for dev (e.g., eastus)."
  default     = "eastus"
}

variable "sku_name" {
  type        = string
  description = "App Service Plan SKU name for dev (e.g., B1)."
  default     = "B1"
}

variable "node_version" {
  type        = string
  description = "Node runtime version for dev."
  default     = "18-lts"
}

variable "tags" {
  type        = map(string)
  description = "Tags for dev resources."
  default     = {
    environment = "dev"
    project     = "terraform-pro"
  }
}