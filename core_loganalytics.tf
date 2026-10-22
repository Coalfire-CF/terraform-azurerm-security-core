# Azure Log Analytics Workspace
# azurerm 5.10.0 has no zone redundancy argument on this resource (R23 not supported here).
resource "azurerm_log_analytics_workspace" "core_la" {
  count = var.create_log_analytics ? 1 : 0

  name                           = local.log_analytics_workspace_name
  location                       = var.location
  resource_group_name            = azurerm_resource_group.core.name
  sku                            = "PerGB2018"
  retention_in_days              = var.retention_in_days
  internet_ingestion_access_type = var.law_internet_ingestion_enabled ? "Enabled" : "Disabled"
  internet_query_access_type     = var.law_internet_query_enabled ? "Enabled" : "Disabled"
  local_authentication_enabled   = var.law_local_authentication_enabled
  data_collection_rule_id        = var.log_analytics_data_collection_rule_id

  tags = local.law_tags

  depends_on = [
    azurerm_resource_group.core
  ]
}

module "diag_law" {
  count = var.create_log_analytics ? 1 : 0

  source                = "git::https://github.com/Coalfire-CF/terraform-azurerm-diagnostics?ref=v3.0.0"
  diag_log_analytics_id = azurerm_log_analytics_workspace.core_la[0].id
  resource_id           = azurerm_log_analytics_workspace.core_la[0].id
  resource_type         = "law"

  depends_on = [azurerm_log_analytics_workspace.core_la]
}

# Query and alert storage linked to the workspace. Created only when this module creates the workspace.
# storage-account v3 owns the container, the diagnostic setting and the optional CMK key.
module "law_queries_sa" {
  source = "git::https://github.com/Coalfire-CF/terraform-azurerm-storage-account?ref=v3.0.0"

  count = local.create_law_queries_storage ? 1 : 0

  name                       = local.law_queries_storage_account_name
  resource_group_name        = azurerm_resource_group.core.name
  location                   = var.location
  account_kind               = "StorageV2"
  replication_type           = var.sa_replication_type
  public_network_access      = var.sa_public_network_access
  ip_rules                   = var.ip_for_remote_access
  virtual_network_subnet_ids = var.sa_subnet_ids
  diag_log_analytics_id      = local.law_id

  endpoint_subnet_id  = var.sa_private_endpoint_subnet_id
  private_dns_zone_id = local.sa_private_dns_zone_id

  storage_containers = ["law-queries"]

  blob_delete_retention_days      = var.sa_blob_delete_retention_days
  container_delete_retention_days = var.sa_container_delete_retention_days
  point_in_time_restore_days      = var.sa_point_in_time_restore_days

  enable_customer_managed_key     = var.enable_customer_managed_key
  cmk_key_vault_id                = module.core_kv.key_vault_id
  cmk_key_type                    = var.fedramp_high ? "RSA-HSM" : "RSA"
  cmk_key_size                    = var.key_size
  cmk_rotation_policy_enabled     = var.rotation_policy_enabled
  cmk_rotation_expire_after       = var.rotation_expire_after
  cmk_rotation_time_before_expiry = var.rotation_time_before_expiry

  tags = local.storage_tags

  # The CMK key write needs the deployer's vault role and, on the private path, the vault private endpoint.
  depends_on = [module.core_kv, azurerm_role_assignment.core_kv_administrator]
}

resource "azurerm_log_analytics_linked_storage_account" "law_queries" {
  count               = local.create_law_queries_storage ? 1 : 0
  data_source_type    = "Query"
  resource_group_name = azurerm_resource_group.core.name
  workspace_id        = azurerm_log_analytics_workspace.core_la[0].id
  storage_account_ids = [module.law_queries_sa[0].id]
}

resource "azurerm_log_analytics_linked_storage_account" "law_alerts" {
  count               = local.create_law_queries_storage ? 1 : 0
  data_source_type    = "Alerts"
  resource_group_name = azurerm_resource_group.core.name
  workspace_id        = azurerm_log_analytics_workspace.core_la[0].id
  storage_account_ids = [module.law_queries_sa[0].id]
}
