# Fichero aks.tf
#
# 09-03-2025 - David Benach Díaz
#
#
# El fichero continene todo lo relacionado con el cluster de k8s
#
# Observaciones:
#     Se crea un servicio AKS con un solo nodo. Se asigna perniso de pull al ACR.
#     Se ejecuta el plybook de Ansible que despliega el pod en AKS.
#     Se recupera la IP pública del servicio de AKS que publica la aplicación en Internet.
#

# Creamos el servicio de k8s con un solo nodo.
resource "azurerm_kubernetes_cluster" "dbd_cp2_aks" {
  name                = "dbdcp2aks"
  location            = azurerm_resource_group.dbd_cp2_rg.location
  resource_group_name = azurerm_resource_group.dbd_cp2_rg.name
  dns_prefix          = "dbdcp2aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"   # Tipo de VM que se usará
  }

  identity {
    type = "SystemAssigned"
  }
}

# Creamos el rol para habilitar el pull desde el AKS al ACR.
resource "azurerm_role_assignment" "dbd_cp2_roleacr" {
  principal_id = azurerm_kubernetes_cluster.dbd_cp2_aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope = azurerm_container_registry.dbd_cp2_acr.id
}

# Recopilamos el nombre del AKS
output "aks_name" {
  value = azurerm_kubernetes_cluster.dbd_cp2_aks.name
  description = "Nombre del servicio AKS"
}

# Contenido del archivo de configuración para interactuar con el AKS vía api service.
output "aks_kubeconfig" {
  value     = azurerm_kubernetes_cluster.dbd_cp2_aks.kube_config_raw
  description = "Contenido del archivo de configuración para la administración del AKS"
  sensitive = true
}

# Guardamos la configuración de acceso al api service de AKS en el directorio home del usuario para poder admnistrar desde el sistema.
resource "null_resource" "guarda_kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.dbd_cp2_aks]

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ~/.kube    # Creamos el directorio .kube en el home del usuario de sistema.
      echo '${azurerm_kubernetes_cluster.dbd_cp2_aks.kube_config_raw}' > ~/.kube/config
      chmod 600 ~/.kube/config     # Copiamos el contenido de kubeconfig al fichero config, que es el que lee kubectl para validarse al AKS.
      EOT
  }
}


# Ejecutamos el playbook de Ansible que va a desplegar el pod en el cluster y crear el servicio de acceso.
resource "null_resource" "despliega_pod" {
  depends_on = [azurerm_role_assignment.dbd_cp2_roleacr]

  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook -i ansible.inv -u dbduser playbook_aks.yml \
      --extra-vars "konfig=~/.kube/config \
                   acr_url=$(terraform output -raw acr_url) acr_user=$(terraform output -raw acr_user) acr_pwd=$(terraform output -raw acr_pwd) \
                   storagename=$(terraform output -raw storage_account_name) storagekey=$(terraform output storage_account_key) storageshare=$(terraform output storage_share_name)"
      EOT
  }
}

# Vamos a guardar la IP por la que se publica la aplicación. Lo hago de esta forma para poder tener un output con la IP. Es la única que permite esperar a que el
#   script de ansible haya finalizado de manera que se cree el load balancer y Azure asigne IP pública.

# Primero, creamos un recurso de datos que redirige a un fichero.
data "local_file" "lee_lb_ip" {
  depends_on = [null_resource.despliega_pod]
  filename = "./terraform.dbd"    # Este fichero contiene la IP del cluster de AKS por donde se publicará la aplicación. Se crea si no existe.
}

# Despues, leemos el recurso de datos para asignar al output el contenido (la IP que contiene el fichero terraform.dbd)
output "lb_public_ip" {
  value = data.local_file.lee_lb_ip.content
  description = "Ip pública de acceso a la aplicación que sirve el AKS"
}
