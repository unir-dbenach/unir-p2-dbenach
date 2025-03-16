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
variable "suscripcion_id" {
  description = "ID de la suscripción de Azure sobre la que se crearan los servicios"
  type        = string
  sensitive   = true
}

# Variable que va a contener el nombre de la zona donde se va a hacer el despliegue.
variable "zona" {
  description = "Zona donde se va a hacer el despliegue"
  type        = string
  default     = "West Europe"
}

# Variable que va a contener el tipo de máquina virtual que usaremos (define las CPUs y la RAM que se asignaran).
variable "tipovm" {
  description = "Tipo de máquina virtual a utilizar"
  type        = string
  default     = "Standard_B2s"
}

# Variable que va a contener el nombre del usuario que se va a dar de alta para acceder y administrar la VM.
variable "usuarioadmin" {
  description = "Nombre del usuario administrador del la VM"
  type        = string
  default     = "dbduser"
}

# Variable que va a contener el nombre del usuario que se va a dar de alta para acceder y administrar la VM.
variable "tipodisco" {
  description = "Tipo de disco a user en la VM"
  type        = string
  default     = "Standard_LRS"
}
