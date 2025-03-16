# Fichero vm.tf
#
# 08-03-2025 - David Benach Díaz
#
# 
# El fichero contiene todo lo relacionado con la máquina virtual.
#
# Observaciones:
#     La máquina virtual tiene asignada IP pública para poder acceder a ella desde Internet. 
#     El acceso solo se permite mediante Key SSH.
#     En este apartado, arranco el playbook de Ansible para configurar la VM que hace:
#        Instala Podman
#        Baja la imagen del contenedor que se instanciará en Podman de docker.io (Apache httpd Server)
#        Personaliza la imagen como se pide en el CP2 (https + htpasswd)
#        La sube al ACR con el tag casopractico2
#        Limpia el Podman para aeliminar rastros del build e imagenes descargadas. 
#        Arranca el contendor en Podman
#        

# Creo la IP pública:
resource "azurerm_public_ip" "dbd_cp2_podmanvm_publicip" {
  name                         = "dbdcp2podmanvmpublicip"
  location                     = azurerm_resource_group.dbd_cp2_rg.location
  resource_group_name          = azurerm_resource_group.dbd_cp2_rg.name
  allocation_method            = "Static"
}

# Nos interesa saber la IP pública que ha asignado Azure:
output "vm_public_ip" {
  value = azurerm_public_ip.dbd_cp2_podmanvm_publicip.ip_address
  description = "Ip pública de la máquina virtual"
}

# Creo la interface de red y asigno la IP pública además de la privada:
resource "azurerm_network_interface" "dbd_cp2_podmanvm_nic" {
  name                      = "dbdcp2podmanvmnic"
  location                  = azurerm_resource_group.dbd_cp2_rg.location
  resource_group_name       = azurerm_resource_group.dbd_cp2_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dbd_cp2_subnet10-0-10-0-24.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.10.10"
    public_ip_address_id          = azurerm_public_ip.dbd_cp2_podmanvm_publicip.id
  }
}

# Nos interesa saber el usuario con el que nos vamos a conectar a la VM:
output "vm_admin_user" {
  value = var.usuarioadmin
  description = "Usuario administrdor de la VM"
}

# Creo la máquina virtual asignando la interface de red:
resource "azurerm_linux_virtual_machine" "dbd_cp2_podmanvm" {
  name                = "dbdcp2podmanvm"
  resource_group_name = azurerm_resource_group.dbd_cp2_rg.name
  location            = azurerm_resource_group.dbd_cp2_rg.location
  size                = var.tipovm
  admin_username      = var.usuarioadmin

  network_interface_ids = [azurerm_network_interface.dbd_cp2_podmanvm_nic.id]

  # Deshabilito el acceso con contraseña y añado la clave pública de acceso:
  disable_password_authentication = true
  admin_ssh_key {
    username   = var.usuarioadmin
    public_key = file("~/.ssh/id_rsa.pub")  # En el PC local debe existir el fichero con la clave pública
  }

  # Tipo de disco que se creará.
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.tipodisco
  }

  # Imagen del sistema que se va a instalar
  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12"
    sku       = "12-gen2"
    version   = "latest"
  }

  #Ejecuto el playbook de Ansible para configurar la VM, bajar la imagen de contenedor de Podman y personalizarla, subir la imagen al ACR y arrancar el contenedor con Podman
  provisioner "local-exec" {
    command = <<EOT
      sleep 30  # espero 30 segundos para asegurar que el servicio ssh en la VM esté levantado
      ansible-playbook -i '${self.public_ip_address},,' -u $(terraform output -raw vm_admin_user) playbook_podman.yml \
      --extra-vars "acr_url=$(terraform output -raw acr_url) acr_user=$(terraform output -raw acr_user) acr_pwd=$(terraform output -raw acr_pwd)"   # Paso las credenciales al Ansible mediante los outputs.
    EOT
  }
}

# Asignación del NSG a la NIC para habilitar el acceso desde Internet:
resource "azurerm_network_interface_security_group_association" "dbd_cp2_podmanmv_nsg" {
  network_interface_id = azurerm_network_interface.dbd_cp2_podmanvm_nic.id
  network_security_group_id = azurerm_network_security_group.dbd_cp2_nsg.id
}
