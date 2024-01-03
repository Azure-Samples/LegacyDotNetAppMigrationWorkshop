##########################################################
## Common Naming Variable
##########################################################

variable "caf_basename" {}

variable "location" {}

variable "resource_group_name" {}

variable "mi_aks_cp_id" {}

variable "la_id" {}

variable "dns_prefix" {}

variable "vnet_subnet_id" {}

variable "kubernetes_version" {
  default = "1.27.7"
}