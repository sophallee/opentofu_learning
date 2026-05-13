# Filename: vm_variables.tf
variable "vm_configs" {
  type = map(object({
    suffix            = string
    vm_size           = string
    ip_address_offset = number
    data_disk_size_gb = number
    db_disk_size_gb   = optional(number)
    image_name        = optional(string)
  }))
  description = "Configuration for different VM types. image_name defaults to custom_image_name when null."
  default = {
    dbsrv1 = {
      suffix            = "DB01"
      vm_size           = "Standard_B4ms"
      ip_address_offset = 4
      data_disk_size_gb = 30
      db_disk_size_gb   = 20
      image_name        = null
    }
    websrv1 = {
      suffix            = "WS01"
      vm_size           = "Standard_B2ms"
      ip_address_offset = 10
      data_disk_size_gb = 30
      db_disk_size_gb   = 20
      image_name        = null
    }
    websrv2 = {
      suffix            = "WS02"
      vm_size           = "Standard_B2ms"
      ip_address_offset = 11
      data_disk_size_gb = 30
      db_disk_size_gb   = null
      image_name        = null
    }
  }
}

variable "vm_sizes" {
  type        = map(string)
  description = "Override VM size per type. Keys: dbsrv1, websrv1, oem. Falls back to vm_configs defaults if not set."
  default     = {}
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