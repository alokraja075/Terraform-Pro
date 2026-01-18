# Cluster Outputs
output "cluster_id" {
  description = "AKS cluster ID"
  value       = module.aks_cluster.cluster_id
}

output "cluster_name" {
  description = "AKS cluster name"
  value       = module.aks_cluster.cluster_name
}

output "cluster_fqdn" {
  description = "AKS cluster FQDN"
  value       = module.aks_cluster.cluster_fqdn
}

output "kube_config" {
  description = "Kubeconfig for the cluster"
  value       = module.aks_cluster.kube_config
  sensitive   = true
}

output "cluster_identity" {
  description = "AKS cluster managed identity"
  value       = module.aks_cluster.cluster_identity
}

output "kubelet_identity" {
  description = "AKS kubelet identity"
  value       = module.aks_cluster.kubelet_identity
}

output "node_resource_group" {
  description = "Node resource group"
  value       = module.aks_cluster.node_resource_group
}

# Network Outputs
output "vnet_id" {
  description = "Virtual network ID"
  value       = azurerm_virtual_network.aks_vnet.id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = azurerm_subnet.aks_subnet.id
}

# Monitoring Outputs
output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = module.aks_cluster.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  value       = module.aks_cluster.log_analytics_workspace_name
}

# ACR Outputs
output "acr_id" {
  description = "Azure Container Registry ID"
  value       = module.aks_cluster.acr_id
}

output "acr_login_server" {
  description = "ACR login server URL"
  value       = module.aks_cluster.acr_login_server
}

# Resource Group Outputs
output "resource_group_name" {
  description = "Resource group name"
  value       = module.aks_cluster.resource_group_name
}

output "resource_group_location" {
  description = "Resource group location"
  value       = module.aks_cluster.resource_group_location
}

# User Node Pool Outputs
output "user_node_pool_id" {
  description = "User node pool ID"
  value       = var.create_user_node_pool ? module.user_node_pool[0].node_pool_id : null
}

output "user_node_pool_name" {
  description = "User node pool name"
  value       = var.create_user_node_pool ? module.user_node_pool[0].node_pool_name : null
}
