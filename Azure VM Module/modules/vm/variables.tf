variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "os_type" {
  description = "Operating system type (Linux or Windows)"
  type        = string
  default     = "Linux"
  
  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be either Linux or Windows."
  }
}

variable "image_publisher" {
  description = "The publisher of the image"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "The offer of the image"
  type        = string
  default     = "0001-com-ubuntu-server-focal"
}

variable "image_sku" {
  description = "The SKU of the image"
  type        = string
  default     = "20_04-lts-gen2"
}

variable "image_version" {
  description = "The version of the image"
  type        = string
  default     = "Latest"
}

variable "admin_username" {
  description = "The username for the admin account"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "The password for the admin account (Windows only)"
  type        = string
  sensitive   = true
  default     = null
}

variable "ssh_public_key" {
  description = "Path to the SSH public key file (Linux only)"
  type        = string
  default     = null
}

variable "os_disk_caching" {
  description = "The type of caching to use on the OS disk"
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  description = "The type of storage account to use for the OS disk"
  type        = string
  default     = "Premium_LRS"
}

variable "subnet_id" {
  description = "The ID of the subnet where the VM will be placed"
  type        = string
}

variable "private_ip_allocation" {
  description = "The allocation method for the private IP address"
  type        = string
  default     = "Dynamic"
}

variable "create_public_ip" {
  description = "Whether to create a public IP address"
  type        = bool
  default     = true
}

variable "security_rules" {
  description = "List of security rules for the NSG"
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
  default = [
    {
      name                       = "AllowSSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowRDP"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHTTP"
      priority                   = 102
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHTTPS"
      priority                   = 103
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

variable "enable_monitoring" {
  description = "Whether to enable monitoring with Log Analytics"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain logs in Log Analytics"
  type        = number
  default     = 30
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Created_by  = "Terraform"
  }
}
