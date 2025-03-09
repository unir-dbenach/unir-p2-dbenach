# Fichero nsg.tf
#
# 08-03-2025 - David Benach Díaz
#
# 
# El fichero contiene todo lo relacionado con la seguridad de acceso via Internet.
#
# Observaciones:
#     Se han defindo reglas para permitir el acceso por el puerto 22 y el puerto 443 para el tráfico TCP
#      

# Definimos el Network Security Group con dos reglas:
resource "azurerm_network_security_group" "dbd_cp2_nsg" {
  name                = "dbdcp2nsg"
  location            = azurerm_resource_group.dbd_cp2_rg.location
  resource_group_name = azurerm_resource_group.dbd_cp2_rg.name

  # Regla para permitir todo el tráfico por el puerto 22 para cualquier origen y a cualquier destino
  security_rule {
    name                       = "permite_ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Regla para permitir todo el tráfico por el puerto 443 para cualquier origen y a cualquier destino
  security_rule {
    name                       = "permite_https"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
