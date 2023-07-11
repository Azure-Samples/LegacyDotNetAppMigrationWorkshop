resource "azurerm_resource_group" "rg" {
  name     = var.name
  location = var.location

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}