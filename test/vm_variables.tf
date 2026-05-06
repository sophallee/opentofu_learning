# Filename: vm_variables.tf
variable "vm_configs" {
  type = map(object({
    suffix            = string
    vm_size           = string
    ip_address_offset = number
    data_disk_size_gb = number
    db_disk_size_gb   = optional(number)
  }))
  description = "Configuration for different VM types"
  default = {
    pmds = {
      suffix            = "DB01"
      vm_size           = "Standard_B4ms"
      ip_address_offset = 4
      data_disk_size_gb = 30
      db_disk_size_gb   = 20
    }
    webapps = {
      suffix            = "WS01"
      vm_size           = "Standard_B2ms"
      ip_address_offset = 10
      data_disk_size_gb = 30
      db_disk_size_gb   = 20
    }
    oem = {
      suffix            = "WS02"
      vm_size           = "Standard_B2ms"
      ip_address_offset = 11
      data_disk_size_gb = 30
      db_disk_size_gb   = null
    }
  }
}

variable "os_disk_type" {
  type        = string
  description = "OS disk type"
  default     = "Premium_LRS"
}

variable "data_disk_type" {
  type        = string
  description = "Data disk type"
  default     = "Premium_LRS"
}

variable "db_disk_type" {
  type        = string
  description = "Database disk type"
  default     = "Premium_LRS"
}