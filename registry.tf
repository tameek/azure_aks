#container registry configuration


resource "azurerm_container_registry" "acr" {
  name                     = "trcontainerRegistry1"
  resource_group_name      = azurerm_resource_group.arg.name
  location                 = azurerm_resource_group.arg.location
  sku                      = "Standard"
  admin_enabled            = true
}

#################################OUTPUTS#################################

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
