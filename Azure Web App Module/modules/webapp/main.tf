locals {
  app_zip_name = "app.zip"
}

resource "random_id" "suffix" {
  byte_length = 3
}

resource "random_id" "sa" {
  byte_length = 6
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.app_name_prefix}-rg-${random_id.suffix.hex}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_service_plan" "plan" {
  name                = "${var.app_name_prefix}-plan-${random_id.suffix.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_storage_account" "sa" {
  name                     = "webapp${random_id.sa.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_storage_container" "packages" {
  name                  = "packages"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

data "archive_file" "app" {
  type        = "zip"
  source_dir  = "${path.module}/app"
  output_path = "${path.module}/${local.app_zip_name}"
}

resource "azurerm_storage_blob" "package" {
  name                   = local.app_zip_name
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.packages.name
  type                   = "Block"
  source                 = data.archive_file.app.output_path
}

data "azurerm_storage_account_sas" "appzip" {
  connection_string = azurerm_storage_account.sa.primary_connection_string
  https_only        = true

  resource_types {
    service  = false
    container = true
    object   = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2026-01-01"
  expiry = "2030-12-31"

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    filter  = false
    tag     = false
  }
}

locals {
  package_url = "https://${azurerm_storage_account.sa.name}.blob.core.windows.net/${azurerm_storage_container.packages.name}/${azurerm_storage_blob.package.name}${data.azurerm_storage_account_sas.appzip.sas}"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "${var.app_name_prefix}-${random_id.suffix.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      node_version = var.node_version
    }
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "true"
    WEBSITE_RUN_FROM_PACKAGE            = local.package_url
  }

  tags = var.tags
}