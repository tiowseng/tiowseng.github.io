# aks nodes subnet


resource "azurerm_subnet" "akssubnet" {
  name                 = "akssubnet"
  resource_group_name  = azurerm_resource_group.akssenfi.name
  virtual_network_name = azurerm_virtual_network.aksvnet.name
  address_prefixes       = ["10.0.1.0/24"]

  # delegation {
  #   name = "delegation"

  #   service_delegation {
  #     name    = "Microsoft.ContainerInstance/containerGroups"
  #     actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetwo  #   }
  # }
}

# AKS cluster definition
resource "azurerm_kubernetes_cluster" "akssenfi" {
  name                  = "akssenfi"
  location              = azurerm_resource_group.akssenfi.location
  resource_group_name   = azurerm_resource_group.akssenfi.name
  dns_prefix            = "akssenfi"
  kubernetes_version    =  var.kubernetes_version

  default_node_pool {
    name       = "default"
    node_count = 1
    //vm_size = "standard_dc4ds_v3"  # southeastasia
    vm_size = "Standard_D2s_v4"    # australiaeast
    //vm_size    = "standard_dc2ds_v3"   # southeastasia
    //vm_size    = "standard_d15_v2"     # southeastasia
    // vm_size   = "Standard_E4s_v3"   # australiaeast
    //vm_size = "standard_dc24ds_v3"
    type       = "VirtualMachineScaleSets"
    // os_disk_size_gb = 250  # australiaeast
    os_disk_size_gb = 64
    enable_node_public_ip = "true"
    vnet_subnet_id = azurerm_subnet.akssubnet.id
  }

  service_principal  {
    client_id = var.serviceprinciple_id
    client_secret = var.serviceprinciple_key
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
        key_data = var.ssh_key
    }
  }

  network_profile {
      network_plugin = "kubenet"
      //network_plugin ="azure"
      load_balancer_sku = "standard"
      pod_cidr              = "172.16.0.0/16"
      service_cidr          = "172.40.0.0/16"
      dns_service_ip        = "172.40.0.10"
      docker_bridge_cidr    = "192.168.25.0/24"
  }

  

}

# identity {
  #   type = "SystemAssigned"
  # }