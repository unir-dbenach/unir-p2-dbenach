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

# Creo la interface de red y asigno la IP pública además de la privada:
resource "azurerm_network_interface" "dbd_cp2_podmanvm_nic" {
  name                      = "dbd_cp2_podmanvmnic"
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

# Creo la máquina virtual asignando la interface de red:
resource "azurerm_linux_virtual_machine" "dbd_cp2_podmanvm" {
  name                = "dbdcp2podmanvm"
  resource_group_name = azurerm_resource_group.dbd_cp2_rg.name
  location            = azurerm_resource_group.dbd_cp2_rg.location
  size                = "Standard_B2s"                                  # Tipo de máquina virtual.
  admin_username      = "dbduser"                                       # Nombre de usuario de sistema.

  network_interface_ids = [azurerm_network_interface.dbd_cp2_podmanvm_nic.id]

  # Deshabilito el acceso con contraseña y añado la clave pública de acceso:
  disable_password_authentication = true
  admin_ssh_key {
    username   = "dbduser"
    public_key = file("~/.ssh/id_rsa.pub")  # En el PC local debe existir el fichero con la clave pública
  }

  # Tipo de disco que se creará.
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
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
      ansible-playbook -i '${self.public_ip_address},,' -u dbduser playbook.yml \
      --extra-vars "acr_url=$(terraform output -raw acr_url) acr_user=$(terraform output -raw acr_user) acr_pwd=$(terraform output -raw acr_pwd)"   # Paso las credenciales al Ansible mediante los outputs.
    EOT
  }
}

# Aginación del NSG a la NIC para habilitar el acceso desde Internet:
resource "azurerm_network_interface_security_group_association" "dbd_cp2_podmanmv_nsg" {
  network_interface_id = azurerm_network_interface.dbd_cp2_podmanvm_nic.id
  network_security_group_id = azurerm_network_security_group.dbd_cp2_nsg.id
}

# Nos interesa saber la IP pública que ha asignado Azure:
output "vm_public_ip" {
  value = azurerm_public_ip.dbd_cp2_podmanvm_publicip.ip_address
}
