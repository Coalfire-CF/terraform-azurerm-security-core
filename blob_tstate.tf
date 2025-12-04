module "tfstate_sa" {
  source = "git::https://github.com/Coalfire-CF/terraform-azurerm-storage-account?ref=v1.1.0"

  count = var.create_tfstate_storage ? 1 : 0

  name                       = local.tfstate_storage_account_name
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
  cmk_key_name                  = module.tstate_cmk[0].key_name
}

resource "azurerm_storage_container" "tf_state_lock" {
  count                 = var.create_tfstate_storage ? 1 : 0
  name                  = "${var.location_abbreviation}${var.app_abbreviation}tfstatecontainer"
  storage_account_id    = module.tfstate_sa[0].id
  container_access_type = "private"
}

module "diag_tf_state_sa" {
  count                 = var.create_tfstate_storage ? 1 : 0
  source                = "git::https://github.com/Coalfire-CF/terraform-azurerm-diagnostics?ref=v1.1.4"
  diag_log_analytics_id = azurerm_log_analytics_workspace.core_la.id
  resource_id           = module.tfstate_sa[0].id
  resource_type         = "sa"
}
