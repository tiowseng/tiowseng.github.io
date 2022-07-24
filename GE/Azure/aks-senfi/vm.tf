## The code below will provision additional VM that will host other non-k8s services such as DB

# Subnet for other senfi VM (db, file, etc) non part of the kubernetes cluster
resource "azurerm_subnet" "senfi-others" {
  name                  = "senfi-others"
  resource_group_name   = azurerm_resource_group.akssenfi.name
  virtual_network_name  = azurerm_virtual_network.aksvnet.name
  address_prefixes        = ["10.0.2.0/24"]
}

# Public IP 1
resource "azurerm_public_ip" "public-ip1" {
  name                = "public-ip1"
  location              = azurerm_resource_group.akssenfi.location
  resource_group_name   = azurerm_resource_group.akssenfi.name
  allocation_method   = "Static"

  # tags = {
  #   environment = "Production"
  # }
}

# NIC for VM1
resource "azurerm_network_interface" "nic1" {
  name                = "nic1"
  location              = azurerm_resource_group.akssenfi.location
  resource_group_name   = azurerm_resource_group.akssenfi.name

  ip_configuration {
    name                          = "nic1"
    subnet_id                     = azurerm_subnet.senfi-others.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public-ip1.id
  }
}

resource "azurerm_network_security_group" "senfivm1-nsg" {
  name                = "senfivm1-nsg"
  location              = azurerm_resource_group.akssenfi.location
  resource_group_name   = azurerm_resource_group.akssenfi.name
}

resource "azurerm_network_security_rule" "ssh" {
  name                       = "ssh"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name         = azurerm_resource_group.akssenfi.name
  network_security_group_name = azurerm_network_security_group.senfivm1-nsg.name
}

resource "azurerm_network_security_rule" "http" {
  name                       = "http"
  priority                   = 110
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "80"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name         = azurerm_resource_group.akssenfi.name
  network_security_group_name = azurerm_network_security_group.senfivm1-nsg.name
}

resource "azurerm_network_security_rule" "https" {
  name                       = "https"
  priority                   = 111
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name         = azurerm_resource_group.akssenfi.name
  network_security_group_name = azurerm_network_security_group.senfivm1-nsg.name
}


resource "azurerm_network_interface_security_group_association" "senfivm1-nsg" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.senfivm1-nsg.id
}

# VM1 - DB, file storage
resource "azurerm_linux_virtual_machine" "senfivm1" {
  name                = "senfivm1"
  location              = azurerm_resource_group.akssenfi.location
  resource_group_name   = azurerm_resource_group.akssenfi.name
  // https://azureprice.net/?region=southeastasia
  // https://docs.microsoft.com/en-us/azure/aks/quotas-skus-regions
  //size                = "Standard_E4s_v3"      # australiaeast
  //size                = "Standard_E2as_v5"      # australiaeast
  size                  = "Standard_D2s_v4"
  //size                  = "Standard_F2" # southeastasia -- not available
  // size                = "standard_dc2ds_v3" # southeastasia -- cannot oot hypervisor Generation '1'. 
  // size = "standard_dc4ds_v3"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    //public_key = file("~/.ssh/id_rsa.pub")
    public_key = var.ssh_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
