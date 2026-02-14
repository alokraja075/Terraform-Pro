variable "app_name_prefix" {
  type        = string
  description = "Prefix for naming Azure resources for the web app."
}

variable "location" {
  type        = string
  description = "Azure region for deployment (e.g., eastus)."
}

variable "sku_name" {
  type        = string
  description = "App Service Plan SKU name (e.g., B1, S1, P1v2)."
  default     = "B1"
}

variable "node_version" {
  type        = string
  description = "Node.js version for the Linux Web App runtime (e.g., 18-lts)."
  default     = "18-lts"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to Azure resources."
  default     = {}
}