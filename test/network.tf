
# Filename: network.tf

resource "azurerm_virtual_network" "vnet" {
  name                = "VNET_${var.customer_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_cidr]

  tags = local.base_tags
}

resource "azurerm_subnet" "customer_subnet" {
  name                 = "NW_${var.customer_name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = [var.subnet_cidr]
}
