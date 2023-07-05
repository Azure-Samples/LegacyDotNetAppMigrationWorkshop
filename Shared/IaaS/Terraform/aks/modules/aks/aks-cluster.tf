
#############
# RESOURCES #
#############

# MSI for Kubernetes Cluster (Control Plane)
# This ID is used by the AKS control plane to create or act on other resources in Azure.
# It is referenced in the "identity" block in the azurerm_kubernetes_cluster resource.

resource "azurerm_user_assigned_identity" "mi-aks-cp" {
  name                = replace(module.CAFResourceNames.names.azurerm_user_assigned_identity, "msi", "aksmsi")
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
}


# Log Analytics Workspace for Cluster

resource "azurerm_log_analytics_workspace" "aks" {
  name                = replace(module.CAFResourceNames.names.azurerm_log_analytics_workspace, "log", "akslog")
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# AKS Cluster

module "aks" {
  source = "./modules/aks"

  caf_basename        = module.CAFResourceNames.names
  dns_prefix          = var.dns_prefix
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  mi_aks_cp_id = azurerm_user_assigned_identity.mi-aks-cp.id
  la_id        = azurerm_log_analytics_workspace.aks.id
}


# This role assigned grants the current user running the deployment admin rights
# to the cluster. In production, you should use just the AAD groups (above).
resource "azurerm_role_assignment" "aks_rbac_admin" {
  scope                = module.aks.aks_id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azurerm_client_config.current.object_id

}

# Role Assignment to Azure Container Registry from AKS Cluster
# This must be granted after the cluster is created in order to use the kubelet identity.

resource "azurerm_role_assignment" "aks-to-acr" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_id
}

# resource "azurerm_key_vault_access_policy" "kv_aks_access_policy" {
#   tenant_id = data.azurerm_client_config.current.tenant_id
#   object_id = local.current_user_id

#   key_permissions    = var.key_permissions
#   secret_permissions = var.secret_permissions
# }

