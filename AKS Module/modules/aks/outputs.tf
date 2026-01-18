output "cluster_id" {
  description = "The AKS cluster ID"
  value       = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "The AKS cluster name"
  value       = azurerm_kubernetes_cluster.main.name
}

output "cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "kube_config" {
  description = "The kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "kube_config_admin" {
  description = "The admin kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.kube_admin_config_raw
  sensitive   = true
}

output "cluster_identity" {
  description = "The managed identity of the AKS cluster"
  value = {
    principal_id = azurerm_kubernetes_cluster.main.identity[0].principal_id
    tenant_id    = azurerm_kubernetes_cluster.main.identity[0].tenant_id
  }
}

output "kubelet_identity" {
  description = "The kubelet identity of the AKS cluster"
  value = {
    client_id   = azurerm_kubernetes_cluster.main.kubelet_identity[0].client_id
    object_id   = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
    user_assigned_identity_id = azurerm_kubernetes_cluster.main.kubelet_identity[0].user_assigned_identity_id
  }
}

output "node_resource_group" {
  description = "The auto-generated resource group containing the AKS cluster resources"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = var.enable_log_analytics ? azurerm_log_analytics_workspace.aks[0].id : null
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace"
  value       = var.enable_log_analytics ? azurerm_log_analytics_workspace.aks[0].name : null
}

output "acr_id" {
  description = "The ID of the Azure Container Registry"
  value       = var.create_acr ? azurerm_container_registry.acr[0].id : null
}

output "acr_login_server" {
  description = "The login server URL for the ACR"
  value       = var.create_acr ? azurerm_container_registry.acr[0].login_server : null
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.aks_rg.name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.aks_rg.location
}
