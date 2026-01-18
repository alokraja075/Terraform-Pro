output "vm_id" {
  description = "The ID of the created virtual machine"
  value       = module.azure_vm.vm_id
}

output "vm_name" {
  description = "The name of the created virtual machine"
  value       = module.azure_vm.vm_name
}

output "private_ip_address" {
  description = "The private IP address of the VM"
  value       = module.azure_vm.private_ip_address
}

output "public_ip_address" {
  description = "The public IP address of the VM"
  value       = module.azure_vm.public_ip_address
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.azure_vm.resource_group_name
}

output "network_interface_id" {
  description = "The ID of the network interface"
  value       = module.azure_vm.network_interface_id
}
