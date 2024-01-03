variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  default     = "rg-appmig-"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "backend_resource_group_name" {
  default = "tfstate"
}

variable "storage_account_name" {
  default = "dplystatestg"
}

variable "container_name" {
  default = "tfstate"
}

variable "dns_prefix" {
  # update this in the .tfvars file
}

variable "dc-vnet-name" {
  default = "app-mig-workshop-vnet"
}

variable "dc-resource_group_name" {
  default = "appmigworkshop"
}

variable "enable_app_insights" {
  default = false
}

variable "enable_prometheus" {
  default = false
}
