variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "dev-vm-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = "dev-vm"
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "os_type" {
  description = "Operating system type"
  type        = string
  default     = "Linux"
}

variable "image_publisher" {
  description = "Image publisher"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Image offer"
  type        = string
  default     = "0001-com-ubuntu-server-focal"
}

variable "image_sku" {
  description = "Image SKU"
  type        = string
  default     = "20_04-lts-gen2"
}

variable "image_version" {
  description = "Image version"
  type        = string
  default     = "Latest"
}

variable "admin_username" {
  description = "Admin username"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for Windows VMs"
  type        = string
  sensitive   = true
  default     = null
}

variable "ssh_public_key" {
  description = "Path to SSH public key for Linux VMs"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID for the VM"
  type        = string
}

variable "create_public_ip" {
  description = "Create a public IP address"
  type        = bool
  default     = true
}

variable "private_ip_allocation" {
  description = "Private IP allocation method"
  type        = string
  default     = "Dynamic"
}

variable "security_rules" {
  description = "Security rules for NSG"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}

variable "enable_monitoring" {
  description = "Enable monitoring with Log Analytics"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Created_by  = "Terraform"
  }
}
