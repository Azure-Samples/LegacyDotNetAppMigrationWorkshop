
data "azurerm_virtual_network" "dc-vnet" {
  name                = var.dc-vnet-name
  resource_group_name = var.dc-resource_group_name
}

# Spoke to Hub
resource "azurerm_virtual_network_peering" "direction1" {
  name                         = "${azurerm_virtual_network.vnet.name}-to-${data.azurerm_virtual_network.dc-vnet.name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = data.azurerm_virtual_network.dc-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Hub to Spoke
resource "azurerm_virtual_network_peering" "direction2" {
  name                         = "${data.azurerm_virtual_network.dc-vnet.name}-to-${azurerm_virtual_network.vnet.name}"
  resource_group_name          = var.dc-resource_group_name
  virtual_network_name         = var.dc-vnet-name
  remote_virtual_network_id    = azurerm_virtual_network.vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}