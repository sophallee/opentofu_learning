
# Filename: network.tf

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_rg  # RG where the VNet already exists
}

resource "azurerm_subnet" "customer_subnet" {
  name                 = "NW_${var.customer_name}"
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name  
  virtual_network_name = data.azurerm_virtual_network.vnet.name                 

  address_prefixes = [var.subnet_cidr]

}
