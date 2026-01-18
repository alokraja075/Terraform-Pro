terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstatesa"
    container_name       = "tfstate"
    key                  = "azure-vm-prod.tfstate"
  }
}

provider "azurerm" {
  features {}
}
