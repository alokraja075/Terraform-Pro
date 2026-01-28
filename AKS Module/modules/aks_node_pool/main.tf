# Additional Node Pool for AKS Cluster
resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  name                  = var.node_pool_name
  kubernetes_cluster_id = var.cluster_id
  vm_size               = var.vm_size
  node_count            = var.node_count
  min_count             = var.enable_auto_scaling ? var.min_count : null
  max_count             = var.enable_auto_scaling ? var.max_count : null
  os_disk_size_gb       = var.os_disk_size_gb
  os_type               = var.os_type
  mode                  = var.mode
  vnet_subnet_id        = var.vnet_subnet_id
  zones                 = var.availability_zones
  max_pods              = var.max_pods
  os_disk_type          = var.os_disk_type
  priority              = var.priority
  eviction_policy       = var.priority == "Spot" ? var.eviction_policy : null
  spot_max_price        = var.priority == "Spot" ? var.spot_max_price : null

  upgrade_settings {
    max_surge = var.max_surge
  }

  dynamic "node_labels" {
    for_each = var.node_labels != null ? [1] : []
    content {
      labels = var.node_labels
    }
  }

  node_taints = var.node_taints

  tags = var.tags

  lifecycle {
    ignore_changes = [
      node_count
    ]
  }
}
