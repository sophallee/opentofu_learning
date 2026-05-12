# Filename: variables.tf
variable "customer_name" {
  type        = string
  description = "Customer name to use in RG, NSG, and tags"
  default     = ""
}

variable "server_prefix" {
  type        = string
  description = "Prefix used for server naming, e.g. AMMM"
  default     = ""
}

variable "vnet_cidr" {
  type        = string
  description = "Address space for the VNet"
  default     = ""
}

variable "subnet_cidr" {
  type        = string
  description = "Subnet CIDR for customer subnet"
  default     = ""
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "australiaeast"
}

variable "allowed_subnets" {
  type        = list(string)
  description = "List of allowed source subnet CIDRs"
  default = [
    "10.0.99.0/24",
    "10.0.98.0/24"
  ]
}

variable "blocked_subnet" {
  type        = string
  description = "Blocked source subnet CIDR"
  default     = "10.0.0.0/16"
}

variable "create_oem" {
  type        = bool
  description = "Whether to create OEM server"
  default     = false
}

variable "image_rg" {
  type        = string
  description = "Resource group containing custom images"
  default     = "development_rg"
}

variable "custom_image_name" {
  type        = string
  description = "Custom image name"
  default     = "almalinux_9_gen2"
}

variable "ssh_username" {
  type        = string
  description = "SSH username"
  default     = "autoit"
}

variable "ssh_password" {
  type        = string
  description = "SSH password"
  default     = "your_default_password_here"
  sensitive   = true
}

