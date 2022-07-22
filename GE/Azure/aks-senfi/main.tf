terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            //version = "=2.46.0"
        }
    }
    backend "azurerm" {
        resource_group_name  = "akssenfi"
        storage_account_name = "akssenfi32355" 
        container_name       = "akssenfi"
        key                  = "terraform.tfstate"
    }

}

provider "azurerm" {
  //version = "=2.5.0"
  skip_provider_registration = "true"
  subscription_id = var.subscription_id
  client_id       = var.serviceprinciple_id
  client_secret   = var.serviceprinciple_key
  tenant_id       = var.tenant_id

  //features {}
  features {
    //resource_group {
    //    prevent_deletion_if_contains_resources = false
    //    }
        }
}

# # module "cluster" {
# #   source                = "./modules/cluster/"
# #   serviceprinciple_id   = var.serviceprinciple_id
# #   serviceprinciple_key  = var.serviceprinciple_key
# #   ssh_key               = var.ssh_key
# #   location              = var.location
# #   kubernetes_version    = var.kubernetes_version
# #   tenant_id             = var.tenant_id
# #   subscription_id       = var.subscription_id

# # }

#cluster resource group
resource "azurerm_resource_group" "akssenfi" {
  name     = "akssenfi"
  location = var.location
}

# # cluster vnet
resource "azurerm_virtual_network" "aksvnet" {
  name                = "aksvnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.akssenfi.location
  resource_group_name = azurerm_resource_group.akssenfi.name
}