variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  default     = "rg-"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "access_key" {
  type      = string
  sensitive = true
}

variable "backend_resource_group_name" {
  default = "tfstate"
}

variable "storage_account_name" {
  default = "dplystatestg"
}

variable "container_name" {
  default = "akscs"
}

variable "dns_prefix" {
  # update this in the .tfvars file
}