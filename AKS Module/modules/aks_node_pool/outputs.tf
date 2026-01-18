output "node_pool_id" {
  description = "The ID of the node pool"
  value       = azurerm_kubernetes_cluster_node_pool.additional.id
}

output "node_pool_name" {
  description = "The name of the node pool"
  value       = azurerm_kubernetes_cluster_node_pool.additional.name
}
