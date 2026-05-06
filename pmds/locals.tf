# Filename: locals.tf
locals {
  base_tags = {
    SITE = var.customer_name
  }
  
  # Calculate network address for IP assignment
  subnet_parts = split(".", var.subnet_cidr)
  subnet_base  = "${local.subnet_parts[0]}.${local.subnet_parts[1]}.${local.subnet_parts[2]}"
  
  # Generate VM names
  vm_names = {
    pmds    = "${var.server_prefix}${var.vm_configs.pmds.suffix}"
    webapps = "${var.server_prefix}${var.vm_configs.webapps.suffix}"
    oem     = "${var.server_prefix}${var.vm_configs.oem.suffix}"
  }
  
  # Generate NIC names
  nic_names = {
    pmds    = "NTW_${local.vm_names.pmds}"
    webapps = "NTW_${local.vm_names.webapps}"
    oem     = "NTW_${local.vm_names.oem}"
  }
  
  # Generate IP addresses
  ip_addresses = {
    pmds    = "${local.subnet_base}.${var.vm_configs.pmds.ip_address_offset}"
    webapps = "${local.subnet_base}.${var.vm_configs.webapps.ip_address_offset}"
    oem     = "${local.subnet_base}.${var.vm_configs.oem.ip_address_offset}"
  }
}