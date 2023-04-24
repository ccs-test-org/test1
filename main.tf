resource "azurerm_resource_group" "ccs_test1" {
  name     = "ccs_test1"
  location = "West Europe"
  tags = {
    yor_trace = "a9bfd380-8406-446a-b90a-6a6bd971681c"
  }
}

resource "azurerm_virtual_network" "ccs_test1_vnet1" {
  name                = "ccs test1 vnet 1"
  location            = azurerm_resource_group.ccs_test1.location
  resource_group_name = azurerm_resource_group.ccs_test1.name
  address_space       = ["10.1.0.0/16"]
  dns_servers         = ["10.1.0.4", "10.1.0.5"]
  subnet {
    name           = "ccs_test1_subnet1"
    address_prefix = "10.1.1.0/24"
  }
  subnet {
    name           = "ccs_test1_subnet2"
    address_prefix = "10.1.2.0/24"
    security_group = azurerm_network_security_group.ccs_test1_nsg1.id
  }
  tags = {
    environment = "Testing"
    owner       = "tplisson"
    yor_trace   = "40139245-6a05-4ea0-9366-b574bebe62de"
  }
}

resource "azurerm_virtual_network" "ccs_test1_vnet2" {
  name                = "ccs test1 vnet 2"
  location            = azurerm_resource_group.ccs_test1.location
  resource_group_name = azurerm_resource_group.ccs_test1.name
  address_space       = ["10.2.0.0/16"]
  dns_servers         = ["10.2.0.4", "10.2.0.5"]
  tags = {
    environment = "Testing"
    owner       = "tplisson"
    yor_trace   = "ff7c7bc2-a992-4868-a409-3092dd3352a8"
  }
}


resource "azurerm_network_security_group" "ccs_test1_nsg1" {
  name                = "ccs test1 terrible nsg"
  location            = azurerm_resource_group.ccs_test1.location
  resource_group_name = azurerm_resource_group.ccs_test1.name
  security_rule {
    name                       = "rule100"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    yor_trace = "5f876f50-8b3b-4661-8803-ffa3aa34bdb7"
  }
}
