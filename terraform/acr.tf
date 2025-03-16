# Fichero acr.tf
#
# 08-03-2025 - David Benach Díaz
#
#
# El fichero contiene todo lo relacionado con los Azure Container Registries.
#
# Observaciones:
#     Solo es necesario un ACR. Se crea el recurso y luego se consulta para extraer la URL de acceso, el nombre de usuario y la contraseña que Azure ha generado para acceder a él ya que se crea con admin_enabled.
#     Con la suscripción de estudiante, no es posible crear un AAD que posibilite crear usuarios con diferentes roles por lo que admin_enabled es la única opción para proteger el acceso al ACR. 
#     El ACR se publica en Internet a través del la URL indicada. Para interactuar con él, es necesario hacer el login con el usuario y la ocntraseña indicados.
#


# Creo el ACR en el RG que se ha dado de alta.
resource "azurerm_container_registry" "dbd_cp2_acr" {
  name                          = "dbdcp2acr"
  resource_group_name           = azurerm_resource_group.dbd_cp2_rg.name
  location                      = azurerm_resource_group.dbd_cp2_rg.location
  sku                           = "Basic"
  admin_enabled                 = true
  public_network_access_enabled = true
}

# Extraigo la URL de acceso.
output "acr_url" {
  value       = azurerm_container_registry.dbd_cp2_acr.login_server
  description = "URL de acceso al ACR"
}

# Extraigo el usuario de acceso.
output "acr_user" {
  value       = azurerm_container_registry.dbd_cp2_acr.admin_username
  description = "Usuario de acceso al ACR"
}

# Extraigo la contraseña de acceso.
output "acr_pwd" {
  value       = azurerm_container_registry.dbd_cp2_acr.admin_password
  description = "Contraseña de acceso al ACR"
  sensitive   = true
}

