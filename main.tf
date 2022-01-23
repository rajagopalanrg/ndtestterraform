variable "location" {}
variable "rg_name" {}
variable "storage_name" {}
variable "storage_tier" {}
variable "storage_repl_type" {}
variable "tfstatefilename" {}

provider "azurerm" {
  
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}
terraform {
  backend "azurerm" {
    resource_group_name  = "learning"
    storage_account_name = "terraformstatefilend"
    container_name       = "statefiles"
    key                  = var.tfstatefilename
  }
}

resource "azurerm_resource_group" "resource_group" {
  location = var.location
  name = var.rg_name
}
resource "azurerm_storage_account" "storage_account" {
  account_replication_type = var.storage_repl_type
  account_tier = var.storage_tier
  location = azurerm_resource_group.resource_group.location
  name = var.storage_name
  resource_group_name = azurerm_resource_group.resource_group.name
}
