output "aks_id" {
  value = module.aks.aks_id
}

output "cluster_name" {
  value = module.aks.cluster_name
}

output "logAnalyticsWorkspaceId" {
  value = azurerm_log_analytics_workspace.aks.id
}