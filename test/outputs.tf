# Filename: output.tf
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vm_names" {
  value = {
    for k, v in local.vm_names :
    k => v if k != "websrv2" || var.create_oem
  }
}

output "vm_ips" {
  value = {
    for k, v in local.ip_addresses :
    k => v if k != "websrv2" || var.create_oem
  }
}

output "nic_names" {
  value = {
    for k, v in local.nic_names :
    k => v if k != "websrv2" || var.create_oem
  }
}

output "ssh_connection_strings" {
  value = {
    for k, v in local.vm_names :
    k => "ssh ${var.ssh_username}@${local.ip_addresses[k]}" if k != "websrv2" || var.create_oem
  }
}