# Filename: locals.tf
locals {
  base_tags = {
    SITE = var.customer_name
  }
  
  # Calculate network address for IP assignment
  subnet_parts = split(".", var.subnet_cidr)
  subnet_base  = "${local.subnet_parts[0]}.${local.subnet_parts[1]}.${local.subnet_parts[2]}"
  
  # Resolve VM sizes — vm_sizes overrides take priority over vm_configs defaults
  effective_vm_sizes = {
    for k, v in var.vm_configs : k => lookup(var.vm_sizes, k, v.vm_size)
  }

  # Generate VM names
  vm_names = {
    dbsrv1    = "${var.server_prefix}${var.vm_configs.dbsrv1.suffix}"
    websrv1 = "${var.server_prefix}${var.vm_configs.websrv1.suffix}"
    websrv2 = "${var.server_prefix}${var.vm_configs.websrv2.suffix}"
  }

  # Generate NIC names
  nic_names = {
    dbsrv1  = "NTW_${local.vm_names.dbsrv1}"
    websrv1 = "NTW_${local.vm_names.websrv1}"
    websrv2 = "NTW_${local.vm_names.websrv2}"
  }

  # Generate IP addresses
  ip_addresses = {
    dbsrv1  = "${local.subnet_base}.${var.vm_configs.dbsrv1.ip_address_offset}"
    websrv1 = "${local.subnet_base}.${var.vm_configs.websrv1.ip_address_offset}"
    websrv2 = "${local.subnet_base}.${var.vm_configs.websrv2.ip_address_offset}"
  }
}