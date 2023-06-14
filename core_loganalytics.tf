resource "azurerm_log_analytics_workspace" "core-la" {
  name                       = "${var.resource_prefix}-la-1"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.core.name
  sku                        = "PerGB2018"
  retention_in_days          = 366
  internet_ingestion_enabled = true
  internet_query_enabled     = true

  tags = merge({
    Function = "SIEM"
    Function = "Core"
  }, var.global_tags, var.regional_tags)

  depends_on = [
    azurerm_resource_group.core
  ]
}
