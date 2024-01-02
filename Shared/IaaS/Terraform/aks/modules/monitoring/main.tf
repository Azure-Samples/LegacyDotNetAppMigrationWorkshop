##############
# CAF MODULE #
##############

module "CAFResourceNames" {
  source      = "../naming"
  workload    = "aksgsma"
  environment = "dev"
  region      = "eus"
  instance    = "001"
}

# Log Analytics for AKS
resource "azurerm_log_analytics_workspace" "spokeLA" {
  name                = replace(module.CAFResourceNames.names.azurerm_log_analytics_workspace, "log", "log")
  location            = azurerm_resource_group.spoke-rg.location
  resource_group_name = azurerm_resource_group.spoke-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30 # has to be between 30 and 730

  daily_quota_gb = 10
}

module "app_insights" {
  source = "/app_insights"
  count = var.enableAppInsights ? 1 : 0
}

module "prometheus" {
  source = "/prometheus"
  count = var.enablePrometheus ? 1 : 0
}

module "container_insights" {
  source = "/container_insights"
  count = var.enableContainerInsights ? 1 : 0
}

#############
## OUTPUTS ##
#############
# These outputs are used by later deployments
output "la_id" {
  value = azurerm_log_analytics_workspace.spokeLA.id
}