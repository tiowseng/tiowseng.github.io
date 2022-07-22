resource "random_string" "random" {
  length  = 8
  special = false
}

resource "azurerm_container_registry" "acrsenfi" {
  name                     = "acrsenfi${random_string.random.result}"
  location                 = azurerm_resource_group.akssenfi.location
  resource_group_name      = azurerm_resource_group.akssenfi.name
  sku                      = "Standard"
  admin_enabled            = true
}