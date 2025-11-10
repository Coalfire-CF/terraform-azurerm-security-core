# Azure Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "core_la" {
  name                       = local.log_analytics_workspace_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.core.name
  sku                        = "PerGB2018"
  retention_in_days          = 366
  internet_ingestion_enabled = true
  internet_query_enabled     = true
  data_collection_rule_id    = var.log_analytics_data_collection_rule_id

  tags = merge({
    Function = "SIEM"
    Plane    = "Core"
  }, var.global_tags, var.regional_tags)

  depends_on = [
    azurerm_resource_group.core
  ]
}

module "diag_law" {
  source                = "git::https://github.com/Coalfire-CF/terraform-azurerm-diagnostics?ref=v1.1.4"
  diag_log_analytics_id = azurerm_log_analytics_workspace.core_la.id
  resource_id           = azurerm_log_analytics_workspace.core_la.id
  resource_type         = "law"
}

module "law_queries_sa" {
  source                     = "git::https://github.com/Coalfire-CF/terraform-azurerm-storage-account?ref=v1.1.4"
  
  count                      = var.create_law_queries_storage ? 1 : 0
  
  name                       = local.law_queries_storage_account_name
  resource_group_name        = azurerm_resource_group.core.name
  location                   = var.location
  account_kind               = "StorageV2"
  ip_rules                   = var.ip_for_remote_access
  diag_log_analytics_id      = azurerm_log_analytics_workspace.core_la.id
  virtual_network_subnet_ids = var.sa_subnet_ids

  tags = merge({
    Function = "Storage"
    Plane    = "Management"
  }, var.global_tags, var.regional_tags)

  public_network_access_enabled = var.sa_public_network_access_enabled
  enable_customer_managed_key   = var.enable_customer_managed_key
  cmk_key_vault_id              = module.core_kv.key_vault_id
  cmk_key_name                  = module.law_queries_cmk[0].key_name
}

resource "azurerm_storage_container" "law_queries" {
  count                 = var.create_law_queries_storage ? 1 : 0
  name                  = "law-queries"
  storage_account_id    = module.law_queries_sa[0].id
  container_access_type = "private"
}

module "diag_la_queries_sa" {
  count                 = var.create_law_queries_storage ? 1 : 0
  source                = "git::https://github.com/Coalfire-CF/terraform-azurerm-diagnostics?ref=v1.1.4"
  diag_log_analytics_id = azurerm_log_analytics_workspace.core_la.id
  resource_id           = module.law_queries_sa[0].id
  resource_type         = "sa"
}

resource "azurerm_log_analytics_linked_storage_account" "law_queries" {
  count                 = var.create_law_queries_storage ? 1 : 0
  data_source_type      = "Query"
  resource_group_name   = azurerm_resource_group.core.name
  workspace_resource_id = azurerm_log_analytics_workspace.core_la.id
  storage_account_ids   = [module.law_queries_sa[0].id]
}

resource "azurerm_log_analytics_linked_storage_account" "law_alerts" {
  count                 = var.create_law_queries_storage ? 1 : 0
  data_source_type      = "Alerts"
  resource_group_name   = azurerm_resource_group.core.name
  workspace_resource_id = azurerm_log_analytics_workspace.core_la.id
  storage_account_ids   = [module.law_queries_sa[0].id]
}
