resource "azurerm_application_insights" "spokeAI" {
  name                = "appInsights"
  location            = var.location
  resource_group_name = var.resourceGroupName
  workspace_id        = var.logAnalyticsWorkspaceId
  application_type    = "web"
}


