provider "azurerm" {
  features {}
  subscription_id = "950677d6-f1a5-4989-ac11-47decf2fc946"
}

resource "azurerm_resource_group" "dbd_cpii_pruebatf" {
  name     = "dbd_cpii_pruebatf"
  location = "West Europe"
}

resource "azurerm_container_registry" "dbd_cpii_pruebatf_acr" {
  name                = "dbdacr"
  resource_group_name = azurerm_resource_group.dbd_cpii_pruebatf.name
  location            = azurerm_resource_group.dbd_cpii_pruebatf.location
  sku                 = "Basic"
  admin_enabled       = false
}
