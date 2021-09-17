resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = "workspace"
  location                     = azurerm_resource_group.arg.location
  resource_group_name         = azurerm_resource_group.arg.name
  friendly_name = "Bastion Desktop"
  description   = "A description of my workspace"
}
