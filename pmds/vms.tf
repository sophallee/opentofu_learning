# Filename: vms.tf
# Data source for custom image (ONE image for all VMs)
data "azurerm_image" "custom" {
  name                = var.custom_image_name
  resource_group_name = var.image_rg
}

# Create network interfaces
resource "azurerm_network_interface" "vm_nics" {
  for_each = { for k in ["pmds", "webapps", "oem"] : k => k if k != "oem" || var.create_oem }

  name                = local.nic_names[each.key]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.customer_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.ip_addresses[each.key]
    public_ip_address_id          = null
  }

  tags = local.base_tags
}

# Create virtual machines
resource "azurerm_linux_virtual_machine" "vms" {
  for_each = { for k in ["pmds", "webapps", "oem"] : k => k if k != "oem" || var.create_oem }

  name                = local.vm_names[each.key]
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = var.vm_configs[each.key].vm_size

  network_interface_ids = [
    azurerm_network_interface.vm_nics[each.key].id
  ]

  admin_username = var.ssh_username
  admin_password = var.ssh_password

  disable_password_authentication = false
  allow_extension_operations      = true

  os_disk {
    name                 = "osdisk-${local.vm_names[each.key]}"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    # Note: azurerm_image doesn't have os_disk_size_gb attribute
    # You need to specify disk size explicitly or use image default
    disk_size_gb = 128  # Set a default value or make it configurable
  }

  source_image_id = data.azurerm_image.custom.id

  tags = local.base_tags

  depends_on = [
    azurerm_network_interface.vm_nics,
    data.azurerm_image.custom
  ]
}

# Create data disks
resource "azurerm_managed_disk" "data_disks" {
  for_each = { for k in ["pmds", "webapps", "oem"] : k => k if k != "oem" || var.create_oem }

  name                 = "datadisk-${local.vm_names[each.key]}"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = var.location
  storage_account_type = var.data_disk_type
  create_option        = "Empty"
  disk_size_gb         = var.vm_configs[each.key].data_disk_size_gb

  tags = local.base_tags
}

# Create database disks (only for PMDS and Webapps)
resource "azurerm_managed_disk" "db_disks" {
  for_each = { for k in ["pmds", "webapps"] : k => k if var.vm_configs[k].db_disk_size_gb != null }

  name                 = "dbdisk-${local.vm_names[each.key]}"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = var.location
  storage_account_type = var.db_disk_type
  create_option        = "Empty"
  disk_size_gb         = var.vm_configs[each.key].db_disk_size_gb

  tags = local.base_tags
}

# Attach data disks to VMs
resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attachments" {
  for_each = { for k in ["pmds", "webapps", "oem"] : k => k if k != "oem" || var.create_oem }

  virtual_machine_id = azurerm_linux_virtual_machine.vms[each.key].id
  managed_disk_id    = azurerm_managed_disk.data_disks[each.key].id
  lun                = 10
  caching            = "ReadWrite"

  depends_on = [
    azurerm_linux_virtual_machine.vms,
    azurerm_managed_disk.data_disks
  ]
}

# Attach database disks to VMs
resource "azurerm_virtual_machine_data_disk_attachment" "db_disk_attachments" {
  for_each = { for k in ["pmds", "webapps"] : k => k if var.vm_configs[k].db_disk_size_gb != null }

  virtual_machine_id = azurerm_linux_virtual_machine.vms[each.key].id
  managed_disk_id    = azurerm_managed_disk.db_disks[each.key].id
  lun                = 20
  caching            = "ReadWrite"

  depends_on = [
    azurerm_linux_virtual_machine.vms,
    azurerm_managed_disk.db_disks,
    azurerm_virtual_machine_data_disk_attachment.data_disk_attachments
  ]
}