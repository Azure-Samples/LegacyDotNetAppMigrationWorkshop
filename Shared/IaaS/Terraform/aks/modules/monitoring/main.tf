##############
# CAF MODULE #
##############

module "CAFResourceNames" {
  source      = "../naming"
  workload    = "aks"
  environment = "dev"
  region      = "eus"
  instance    = "001"
}

# Log Analytics for AKS
resource "azurerm_log_analytics_workspace" "spokeLA" {
  name                = replace(module.CAFResourceNames.names.azurerm_log_analytics_workspace, "log", "log")
  location            = var.location
  resource_group_name = var.resourceGroupName
  sku                 = "PerGB2018"
  retention_in_days   = 30 # has to be between 30 and 730

  daily_quota_gb = 10
}

module "app_insights" {
  source = "./app_insights"
  count = var.enableAppInsights ? 1 : 0
  resourceGroupName = var.resourceGroupName
  location = var.location
  logAnalyticsWorkspaceId = azurerm_log_analytics_workspace.spokeLA.id
}

module "prometheus" {
  source = "./prometheus"
  count = var.enablePrometheus ? 1 : 0
  resourceGroupName = var.resourceGroupName
  location = var.location
  clusterName = var.clusterName
  clusterId = var.clusterId
  uniqueSuffix = var.uniqueSuffix
}

#############
## OUTPUTS ##
#############
# These outputs are used by later deployments
output "la_id" {
  value = azurerm_log_analytics_workspace.spokeLA.id
}