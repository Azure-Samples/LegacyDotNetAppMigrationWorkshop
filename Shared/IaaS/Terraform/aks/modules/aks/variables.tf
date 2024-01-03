#############
# VARIABLES #
#############

variable "dns_prefix" {
  # update this in the .tfvars file
}

variable "resource_group_name" {}

variable "resource_group_location" {}

variable "container_registry_id" {}

variable "key_vault_id" {}

variable "backend_resource_group_name" {
  default = "tfstate"
}

variable "storage_account_name" {
  default = "dplystatestg"
}

variable "container_name" {
  default = "akscs"
}

variable "vnet_subnet_id" {}
