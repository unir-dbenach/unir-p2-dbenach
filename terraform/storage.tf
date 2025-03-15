# Fichero storage.tf
#
# 09-03-2025 - David Benach Díaz
#
#
# El fichero continene todo lo relacionado con el storage de Azure.
#
# Observaciones:
#     Creamos un recurso de storage con un share de un 1GB.
#  

# Creamos el recurso de storage
resource "azurerm_storage_account" "dbd_cp2_storage" {
  name                     = "dbdcp2storage"
  resource_group_name      = azurerm_resource_group.dbd_cp2_rg.name
  location                 = azurerm_resource_group.dbd_cp2_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
} 

# Creamos el share que nos permitirá ver el espacio de storage
resource "azurerm_storage_share" "dbd_cp2_storage_share" {
  name                 = "dbdcp2storageshare"
  storage_account_id = azurerm_storage_account.dbd_cp2_storage.id
  quota               = 1  # GB
}

# Recopilamos el nombre del recurso de storage
output "storage_account_name" {
  value = azurerm_storage_account.dbd_cp2_storage.name
  description = "Nombre del recurso de storage."
} 

# Recopilamos la key para validar al storage
output "storage_account_key" {
  value     = azurerm_storage_account.dbd_cp2_storage.primary_access_key
  description = "Key de acceso al recurso de storage"
  sensitive = true
}

# Recopilamos el nombre del share
output "storage_share_name" {
  value = azurerm_storage_share.dbd_cp2_storage_share.name
  description = "Nombre del share"
}
