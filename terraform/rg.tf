# Fichero rg.tf
#
# 08-03-2025 - David Benach Díaz
#
#
# El fichero contiene todo lo relacionado con los resource groups sobre los que se van a crear los servicios.
#
# Observaciones:
#     En nuestro caso, solo crearemos un Resource Group que agrupará todos los servicios.
#
#

# Definición del resource group:
resource "azurerm_resource_group" "dbd_cp2_rg" {
  name     = "dbdcp2rg"
  location = var.zona
}
