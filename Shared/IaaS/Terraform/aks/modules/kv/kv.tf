data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "vault" {
  name                        = replace(var.caf_basename, var.caf_instance, "${var.random_instance}")
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = 7
}

resource "random_string" "azurerm_key_vault_key_name" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}

