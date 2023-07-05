##############
# CAF MODULE #
##############

module "CAFResourceNames" {
  source      = "../naming"
  workload    = "aksg"
  environment = "dev"
  region      = "eus"
  instance    = "001"
}

data "azurerm_client_config" "current" {}