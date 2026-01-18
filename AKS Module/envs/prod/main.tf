# Virtual Network for AKS
resource "azurerm_resource_group" "network_rg" {
  name     = "${var.cluster_name}-network-rg"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = "${var.cluster_name}-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  tags                = var.common_tags
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.cluster_name}-subnet"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

# AKS Cluster Module
module "aks_cluster" {
  source = "../../modules/aks"

  resource_group_name = var.resource_group_name
  location            = var.location
  cluster_name        = var.cluster_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier

  # Default Node Pool
  default_node_pool_name           = var.default_node_pool_name
  default_node_pool_vm_size        = var.default_node_pool_vm_size
  default_node_pool_node_count     = var.default_node_pool_node_count
  default_node_pool_min_count      = var.default_node_pool_min_count
  default_node_pool_max_count      = var.default_node_pool_max_count
  enable_auto_scaling              = var.enable_auto_scaling
  default_node_pool_os_disk_size_gb = var.default_node_pool_os_disk_size_gb
  availability_zones               = var.availability_zones

  # Network
  vnet_subnet_id     = azurerm_subnet.aks_subnet.id
  network_plugin     = var.network_plugin
  network_policy     = var.network_policy
  dns_service_ip     = var.dns_service_ip
  service_cidr       = var.service_cidr
  load_balancer_sku  = var.load_balancer_sku

  # Azure AD Integration
  enable_azure_ad_integration    = var.enable_azure_ad_integration
  azure_ad_admin_group_object_ids = var.azure_ad_admin_group_object_ids
  azure_rbac_enabled             = var.azure_rbac_enabled

  # Monitoring and Logging
  enable_log_analytics          = var.enable_log_analytics
  log_analytics_workspace_sku   = var.log_analytics_workspace_sku
  log_retention_in_days         = var.log_retention_in_days
  enable_microsoft_defender     = var.enable_microsoft_defender

  # Key Vault Secrets Provider
  enable_key_vault_secrets_provider = var.enable_key_vault_secrets_provider
  secret_rotation_enabled           = var.secret_rotation_enabled
  secret_rotation_interval          = var.secret_rotation_interval

  # Other Settings
  enable_http_application_routing = var.enable_http_application_routing
  enable_private_cluster          = var.enable_private_cluster

  # Azure Container Registry
  create_acr        = var.create_acr
  acr_name          = var.acr_name
  acr_sku           = var.acr_sku
  acr_admin_enabled = var.acr_admin_enabled

  tags = var.common_tags
}

# Additional Node Pool for User Workloads
module "user_node_pool" {
  count  = var.create_user_node_pool ? 1 : 0
  source = "../../modules/aks_node_pool"

  node_pool_name      = var.user_node_pool_name
  cluster_id          = module.aks_cluster.cluster_id
  vm_size             = var.user_node_pool_vm_size
  node_count          = var.user_node_pool_node_count
  min_count           = var.user_node_pool_min_count
  max_count           = var.user_node_pool_max_count
  enable_auto_scaling = var.enable_auto_scaling
  os_disk_size_gb     = var.user_node_pool_os_disk_size_gb
  vnet_subnet_id      = azurerm_subnet.aks_subnet.id
  availability_zones  = var.availability_zones
  mode                = "User"
  node_labels         = var.user_node_pool_labels
  node_taints         = var.user_node_pool_taints

  tags = var.common_tags
}

# Spot Node Pool for cost optimization (Optional)
module "spot_node_pool" {
  count  = var.create_spot_node_pool ? 1 : 0
  source = "../../modules/aks_node_pool"

  node_pool_name      = var.spot_node_pool_name
  cluster_id          = module.aks_cluster.cluster_id
  vm_size             = var.spot_node_pool_vm_size
  node_count          = var.spot_node_pool_node_count
  min_count           = var.spot_node_pool_min_count
  max_count           = var.spot_node_pool_max_count
  enable_auto_scaling = var.enable_auto_scaling
  os_disk_size_gb     = var.spot_node_pool_os_disk_size_gb
  vnet_subnet_id      = azurerm_subnet.aks_subnet.id
  availability_zones  = var.availability_zones
  mode                = "User"
  priority            = "Spot"
  eviction_policy     = var.spot_eviction_policy
  spot_max_price      = var.spot_max_price
  node_labels         = var.spot_node_pool_labels
  node_taints         = var.spot_node_pool_taints

  tags = var.common_tags
}
