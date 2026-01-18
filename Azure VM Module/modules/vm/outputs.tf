output "vm_id" {
  description = "The ID of the created virtual machine"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine.vm[0].id : azurerm_windows_virtual_machine.vm_windows[0].id
}

output "vm_name" {
  description = "The name of the created virtual machine"
  value       = var.vm_name
}

output "private_ip_address" {
  description = "The private IP address assigned to the VM"
  value       = azurerm_network_interface.vm_nic.private_ip_address
}

output "public_ip_address" {
  description = "The public IP address assigned to the VM"
  value       = var.create_public_ip ? azurerm_public_ip.vm_pip[0].ip_address : null
}

output "network_interface_id" {
  description = "The ID of the network interface"
  value       = azurerm_network_interface.vm_nic.id
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.vm_rg.id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.vm_rg.name
}

output "network_security_group_id" {
  description = "The ID of the network security group"
  value       = azurerm_network_security_group.vm_nsg.id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = var.enable_monitoring ? azurerm_log_analytics_workspace.vm_workspace[0].id : null
}
