##############
# CAF MODULE #
##############

module "CAFResourceNames" {
  source      = "../naming"
  workload    = "gsma"
  environment = "dev"
  region      = "eus"
  instance    = "001"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "akssnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.1.0.0/16"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.1.1.0/24"
  }
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "subnet_id" {
  value = element(tolist(azurerm_virtual_network.vnet.subnet),0).id
}
output "subnet_name" {
  value  =  element(tolist(azurerm_virtual_network.vnet.subnet),0).name
}
  
