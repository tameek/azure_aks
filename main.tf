module "aks" {
  source = "./.terraform/modules/"
}

resource "azurerm_resource_group" "arg" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_dns_zone" "apdz" {
  name                = "aks2.thetaraycs.com"
  resource_group_name = azurerm_resource_group.arg.name
}

resource "azurerm_private_dns_zone" "apdz" {
  name                = "aks2.thetaraycs.com"
  resource_group_name = azurerm_resource_group.arg.name
}

resource "azurerm_user_assigned_identity" "auai" {
  name                = "kubeadminid"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location
}

resource "azurerm_role_assignment" "ara" {
  scope                = azurerm_private_dns_zone.apdz.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.auai.principal_id
}


resource "azurerm_public_ip" "api" {
  name                = "${var.prefix}PublicIp1"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}


resource "azurerm_network_security_group" "ansg" {
  name                = "networksecuritygroup"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.arg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.ContainerRegistry", "Microsoft.AzureActiveDirectory"]

  delegation {
    name = "aciDelegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
   }
}
resource "azurerm_subnet" "external" {
  name                 = "external"
  resource_group_name  = azurerm_resource_group.arg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "asnsga" {
  subnet_id                 = azurerm_subnet.external.id
  network_security_group_id = azurerm_network_security_group.ansg.id
}


resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}aks"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name
  kubernetes_version  = "1.19.11"
  private_cluster_enabled = "false"
  dns_prefix          = "tamir"
#    api_server_authorized_ip_ranges = ["192.168.0.0/16"]

  tags = {
    Environment = "lab"
  }

  auto_scaler_profile {
    balance_similar_node_groups = "false"
    expander                    = "least-waste"
  }

  default_node_pool {
#    max_pods = "2"
    name = "noodpool"
    node_count = "1"
    #orchestration =
    os_disk_size_gb = "100"
    os_disk_type = "Managed"
    type = "VirtualMachineScaleSets"
    vm_size = "Standard_D16s_v4"
#    vnet_subnet_id = azurerm_subnet.asa.id
  }
    identity {
    type = "SystemAssigned"
  }

    network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "Standard"
  }

#    api_server_authorized_ip_ranges {
#
#    }


  addon_profile {
    aci_connector_linux {
     enabled = false
    }
    azure_policy {
      enabled = "false"
    }
    http_application_routing {
      enabled      = "true"
    }
    kube_dashboard {
      enabled = "false"
    }
  }

  role_based_access_control {
      enabled = "true"
      azure_active_directory {
        managed = "true"
        admin_group_object_ids = var.admingroup
          azure_rbac_enabled = "true"
     }
  }

    depends_on = [
    azurerm_role_assignment.ara
  ]
  }
