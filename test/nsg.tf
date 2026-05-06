# Filename: nsg.tf

resource "azurerm_network_security_group" "nsg" {
  name                = "NSG_${var.customer_name}"           # NSG name includes customer_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name      # Link to RG

  tags = local.base_tags
}

resource "azurerm_network_security_rule" "allow_in" {
  name                        = "Allow_In"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"

  source_port_range           = "*"
  destination_port_range      = "*"

  source_address_prefixes     = concat(var.allowed_subnets, [var.subnet_cidr])
  destination_address_prefix  = "*"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name

  depends_on = [azurerm_network_security_group.nsg]   
}

resource "azurerm_network_security_rule" "deny_in" {
  name                        = "Deny_In"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"

  source_port_range           = "*"
  destination_port_range      = "*"

  source_address_prefix       = var.blocked_subnet
  destination_address_prefix  = "*"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name

  depends_on = [azurerm_network_security_group.nsg]
}

# Attach NSG to subnet
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.customer_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id

  depends_on = [
    azurerm_subnet.customer_subnet,       # ensure subnet exists
    azurerm_network_security_group.nsg    # ensure NSG exists
  ]
}

