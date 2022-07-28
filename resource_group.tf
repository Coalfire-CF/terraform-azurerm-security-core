resource "azurerm_resource_group" "core" {
  name     = var.core_rg_name
  location = var.location

  lifecycle {
    prevent_destroy = true
  }
}
