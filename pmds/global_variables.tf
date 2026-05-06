# Filename: global_variables.tf
# CAUTION: DO NOT UPDATE RESOURCES REFERENCED IN THESE VARIABLES

variable "vnet_name" {
  type        = string
  description = "Virtual Network name"
  default     = "development-rg-vnet"
}

variable "vnet_rg" {
  type        = string
  description = "VNET resourge group"
  default     = "development-rg"
}
