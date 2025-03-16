# Fichero main.tf
#
# 08-03-2025 - David Benach Díaz
#
# 
# El fichero continene todo lo relacionado con la definición del proveedor. En este caso, Azure.
#
# Observaciones:
#     Para ejecutar la creación de la infraestructura, se deberá ejecutar az login previamente a causa de no existir un Service Principal que permita conectar automáticamente 
#        dado que no es posible crearlo con una suscripción de estudiante.
#      

# Proveedor y versión a descargar (versión compatible dentro del rango 4.x)
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Suscripción de Azure bajo la que se desplegaran los servicios.
provider "azurerm" {
  features {}
  subscription_id = var.suscripcion_id  # Almacenamos el dato en una variable para no tenerlo en claro en el fichero. Ver var.tf para más detalles.
}
