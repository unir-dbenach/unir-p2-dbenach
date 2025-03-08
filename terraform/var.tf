# Fichero var.tf
#
# 08-03-2025 - David Benach Díaz
#
# 
# El fichero contiene las variables que se han definido en el código de Terraform.
#
# Observaciones:
#     Algunas variables indicadas se definen para ocultar datos sensibles en el código. Estas obtienen el valor del fichero terraform.tfvars. 
#     El resto de variables están relacionadas con las opciones que se pueden escoger en los servicios.
#   

# Variable que va a contener el id de la suscripción. No se define default. Se debería asignar a través del fichero terraform.tfvars. Si no se asigna, la pregunta al ejecutar el plan.
variable "subscripcion_id" {
  description = "ID de la subscripción de Azure sobre la que se crearan los servicios"
  type        = string
  sensitive   = true
}
