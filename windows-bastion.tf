resource "azurerm_public_ip" "windows-bastionpubip" {
    name                         = "windows-bastionpubip"
    location                     = azurerm_resource_group.arg.location
    resource_group_name         = azurerm_resource_group.arg.name
    allocation_method            = "Static"

  tags = {
    Environment = "lab"
  }
}

resource "azurerm_network_interface" "windows-bastion-nic" {
    name                        = "windows-bastion-nic"
    location                    = azurerm_resource_group.arg.location
    resource_group_name         = azurerm_resource_group.arg.name
 #   network_security_group_id   = azurerm_network_security_group.jumpHostSecurityGroup.id

    ip_configuration {
        name                          =  "windows-bastion-nic-ip"
        subnet_id                     =  azurerm_subnet.external.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          =  azurerm_public_ip.windows-bastionpubip.id
    }

  tags = {
    Environment = "lab"
  }
}

resource "azurerm_windows_virtual_machine" "windowsbastion" {
  name                = "windows-machine"
  location                     = azurerm_resource_group.arg.location
  resource_group_name         = azurerm_resource_group.arg.name
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.windows-bastion-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
