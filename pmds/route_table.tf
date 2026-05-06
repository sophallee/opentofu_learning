# Filename: route_table.tf

resource "azurerm_route_table" "rt" {
  name                = "Route_${var.customer_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.base_tags
}

# Internet Route
resource "azurerm_route" "internet_route" {
  name                   = "Internet_Route"
  resource_group_name    = azurerm_resource_group.rg.name
  route_table_name       = azurerm_route_table.rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "10.1.0.254"
}

# LAN Route
resource "azurerm_route" "lan_route" {
  name                 = "LAN_Route"
  resource_group_name  = azurerm_resource_group.rg.name
  route_table_name     = azurerm_route_table.rt.name
  address_prefix       = var.subnet_cidr
  next_hop_type        = "VnetLocal"
  depends_on           = [azurerm_subnet.customer_subnet]
}

# Associate Route Table to Subnet
resource "azurerm_subnet_route_table_association" "rt_assoc" {
  subnet_id      = azurerm_subnet.customer_subnet.id
  route_table_id = azurerm_route_table.rt.id
}