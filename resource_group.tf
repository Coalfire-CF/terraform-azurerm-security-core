resource "azurerm_resource_group" "core" {
  name     = var.core_rg_name
  location = var.location
  tags     = local.caller_tags

  lifecycle {
    prevent_destroy = true
  }
}
