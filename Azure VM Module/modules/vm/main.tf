terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Azure Resource Group
resource "azurerm_resource_group" "vm_rg" {
  name       = var.resource_group_name
  location   = var.location
  tags       = var.tags
}

# Network Interface
resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name

  ip_configuration {
    name                          = "testConfiguration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_allocation
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.vm_pip[0].id : null
  }

  tags = var.tags
}

# Public IP (Optional)
resource "azurerm_public_ip" "vm_pip" {
  count               = var.create_public_ip ? 1 : 0
  name                = "${var.vm_name}-pip"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
  allocation_method   = "Static"

  tags = var.tags
}

# Network Security Group
resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${var.vm_name}-nsg"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name

  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  tags = var.tags
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "vm_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.os_type == "Linux" ? 1 : 0
  name                = var.vm_name
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
  size                = var.vm_size

  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  admin_username = var.admin_username

  dynamic "admin_ssh_key" {
    for_each = var.ssh_public_key != null ? [1] : []
    content {
      username   = var.admin_username
      public_key = file(var.ssh_public_key)
    }
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "vm_windows" {
  count               = var.os_type == "Windows" ? 1 : 0
  name                = var.vm_name
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
  size                = var.vm_size

  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  admin_username = var.admin_username
  admin_password = var.admin_password

  tags = var.tags
}

# Optional: Log Analytics Workspace Integration
resource "azurerm_log_analytics_workspace" "vm_workspace" {
  count               = var.enable_monitoring ? 1 : 0
  name                = "${var.vm_name}-law"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = var.tags
}
