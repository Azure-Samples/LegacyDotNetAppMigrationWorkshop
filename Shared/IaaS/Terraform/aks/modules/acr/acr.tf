resource "azurerm_container_registry" "acr" {
  name                          = replace(var.caf_basename, var.caf_instance, "${var.random_instance}")
  resource_group_name           = var.resource_group_name
  location                      = var.resource_group_location
  sku                           = "Premium"
  public_network_access_enabled = false
}