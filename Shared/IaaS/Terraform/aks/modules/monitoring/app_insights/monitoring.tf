resource "azurerm_application_insights" "spokeAI" {
  name                = "appInsights"
  location            = vars.location
  resource_group_name = vars.resourceGroupName
  workspace_id        = vars.logAnalyticsWorkspaceId
  application_type    = "web"
}


