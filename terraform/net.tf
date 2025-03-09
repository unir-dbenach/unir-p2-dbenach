# Fichero net.tf
#
# 08-03-2025 - David Benach Díaz
#
# 
# El fichero continene todo lo relacionado con la red definida.
#
# Observaciones:
#     Se usará la red con direccionamiento 10.0.0.0/16 en la que se definirá una subred 10.0.10.0/24.
#  

# Creo una red virtual. Uso el rango 10.0.0.0/16:
resource "azurerm_virtual_network" "dbd_cp2_net10-0-0-0-16" {
  name                = "dbdcp2net10d0d0d0s16"
  location            = azurerm_resource_group.dbd_cp2_rg.location
  resource_group_name = azurerm_resource_group.dbd_cp2_rg.name
  address_space       = ["10.0.0.0/16"]
}

# Creo la subred donde se conectaran las máquinas (rango 10.0.10.0/24):
resource "azurerm_subnet" "dbd_cp2_subnet10-0-10-0-24" {
  name                 = "dbdcp2subnet10d0d10d0s24"
  resource_group_name  = azurerm_resource_group.dbd_cp2_rg.name
  virtual_network_name = azurerm_virtual_network.dbd_cp2_net10-0-0-0-16.name
  address_prefixes     = ["10.0.10.0/24"]
}
