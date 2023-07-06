##############
# CAF MODULE #
##############

module "CAFResourceNames" {
  source      = "./modules/naming"
  workload    = "aksg"
  environment = "dev"
  region      = "eus"
  instance    = "001"
}

resource "random_string" "rg_name" {
  length = 4
  lower = true
}

resource "random_integer" "deployment" {
  min = 010
  max = 999
}

# Create a resource group for this deployment
module "resource_group" {
  source   = "./modules/rg"
  location = var.resource_group_location
  name     = "${var.resource_group_name_prefix}${random_string.rg_name.id}"
}

module "azure_key_vault"{
  source = "./modules/kv"
  caf_basename = module.CAFResourceNames.names.azurerm_key_vault
  caf_instance        = module.CAFResourceNames.instance
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  sku_name = "standard"
  random_instance = random_integer.deployment.result
}

module "azure_container_registry"{
  source = "./modules/acr"
  resource_group_name = module.resource_group.name
  resource_group_location = module.resource_group.location
  caf_basename        = module.CAFResourceNames.names
  caf_instance        = module.CAFResourceNames.instance
  random_instance     = random_integer.deployment.result
}

module "aks_cluster" {
  source = "./modules/aks"
  access_key = var.access_key
  resource_group_location = module.resource_group.location
  resource_group_name = module.resource_group.name
  dns_prefix = var.dns_prefix
  container_registry_id = module.azure_container_registry.acr_id
  key_vault_id = module.azure_key_vault.azurerm_key_vault_id
}