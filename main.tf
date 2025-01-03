resource "azurerm_resource_group" "ccs_test1" {
  name     = "ccs_test1"
  location = "West Europe"
  tags = {
    yor_name  = "ccs_test1"
    yor_trace = "99ff7c2d-c874-42b0-a27f-6de857235df1"
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
    yor_name    = "ccs_test1_vnet1"
    yor_trace   = "d38ea610-7d57-401b-b43c-2704a1a6d83a"
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
    yor_name    = "ccs_test1_vnet2"
    yor_trace   = "931137a4-c3fb-4b91-808a-879c71971b6f"
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
    yor_name  = "ccs_test1_nsg1"
    yor_trace = "f5200269-62ad-4be3-88af-28fe2e474da7"
  }
}
