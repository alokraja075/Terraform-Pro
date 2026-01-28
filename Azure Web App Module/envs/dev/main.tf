provider "azurerm" {
  features {}
}

module "webapp" {
  source          = "../../modules/webapp"
  app_name_prefix = var.app_name_prefix
  location        = var.location
  sku_name        = var.sku_name
  node_version    = var.node_version
  tags            = var.tags
}