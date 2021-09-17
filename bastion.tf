resource "azurerm_public_ip" "linux-bastionpubip" {
    name                         = "linux-bastionpubip"
    location                     = azurerm_resource_group.arg.location
    resource_group_name         = azurerm_resource_group.arg.name
    allocation_method            = "Static"

  tags = {
    Environment = "lab"
  }
}

resource "azurerm_network_interface" "linux-bastion-nic" {
    name                        = "linux-bastion-nic"
    location                    = azurerm_resource_group.arg.location
    resource_group_name         = azurerm_resource_group.arg.name

    ip_configuration {
        name                          =  "linux-bastion-nic-ip"
        subnet_id                     =  azurerm_subnet.external.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          =  azurerm_public_ip.linux-bastionpubip.id
    }

  tags = {
    Environment = "lab"
  }
}

resource "azurerm_virtual_machine" "avm" {
  name                = "kube-bastion"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true
    network_interface_ids = [
    azurerm_network_interface.linux-bastion-nic.id,
  ]

  storage_os_disk {
    name                 = "osdisk"
    caching              = "ReadWrite"
    create_option        = "FromImage"
  }

  os_profile {
    computer_name  = "bastion.aks.thetaraycs.com"
    admin_username = "deploy"
    admin_password = "&#($HEWP)token"
  }

  os_profile_linux_config {
    disable_password_authentication = false
      ssh_keys {
    key_data = file("/Users/tameekhenderson/.ssh/id_rsa.pub")
    path = "/home/deploy/.ssh/authorized_keys"
    }
  }

  storage_image_reference {
    id = var.vmid
#    create_option        = "FromImage"
  }

    tags = {
    Environment = "lab"
    }
}
