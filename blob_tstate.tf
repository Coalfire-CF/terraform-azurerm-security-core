# ## Blob Storage Account for Terraform State with CMK ##
# resource "azurerm_storage_account" "tf_state" {
#   count                             = var.create_tfstate_storage ? 1 : 0
#   depends_on                        = [azurerm_resource_group.core]
#   name                              = local.tfstate_storage_account_name
#   resource_group_name               = azurerm_resource_group.core.name
#   location                          = var.location
#   account_tier                      = "Standard"
#   account_replication_type          = "GRS"
#   min_tls_version                   = "TLS1_2"
#   https_traffic_only_enabled        = true
#   allow_nested_items_to_be_public   = false
#   public_network_access_enabled     = true #controlled with firewall rules 
#   infrastructure_encryption_enabled = true

#   identity {
#     type = "SystemAssigned"
#   }
#   lifecycle {
#     prevent_destroy = true
#     ignore_changes = [
#       customer_managed_key # required by https://github.com/hashicorp/terraform-provider-azurerm/issues/16085
#     ]
#   }
#   blob_properties {
#     versioning_enabled = true
#   }

#   tags = merge({
#     Function = "Storage"
#     Plane    = "Core"
#   }, var.global_tags, var.regional_tags)
# }

module "tfstate_sa" {
  source                     = "git::https://github.com/Coalfire-CF/terraform-azurerm-storage-account?ref=fix/storage-cmk"
  
  count                      = var.create_tfstate_storage ? 1 : 0
  
  name                       = local.tfstate_storage_account_name
  resource_group_name        = azurerm_resource_group.core.name
  location                   = var.location
  account_kind               = "StorageV2"
  ip_rules                   = var.ip_for_remote_access
  diag_log_analytics_id      = var.diag_log_analytics_id
  virtual_network_subnet_ids = var.fw_virtual_network_subnet_ids

  tags = merge({
    Function = "Storage"
    Plane    = "Management"
  }, var.global_tags, var.regional_tags)

  public_network_access_enabled = var.public_network_access_enabled
  enable_customer_managed_key   = var.enable_customer_managed_key
  cmk_key_vault_id              = module.core_kv.key_vault_id
  cmk_key_name                  = module.tstate_cmk[0].key_name
}


resource "azurerm_role_assignment" "tstate_kv_crypto_user" {
  count                = var.create_tfstate_storage ? 1 : 0
  scope                = module.core_kv.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = module.tfstate_sa[0].managed_principal_id
}

resource "azurerm_storage_account_customer_managed_key" "enable_tstate_cmk" {
  count              = var.create_tfstate_storage ? 1 : 0
  storage_account_id = module.tfstate_sa[0].id
  key_vault_id       = module.core_kv.key_vault_id
  key_name           = module.tstate_cmk[0].key_name

  depends_on = [ azurerm_role_assignment.tstate_kv_crypto_user ]
}

resource "azurerm_storage_container" "tf_state_lock" {
  count                 = var.create_tfstate_storage ? 1 : 0
  name                  = "${var.location_abbreviation}${var.app_abbreviation}tfstatecontainer"
  storage_account_id    = module.tfstate_sa[0].id
  container_access_type = "private"
}

module "diag_tf_state_sa" {
  count                 = var.create_tfstate_storage ? 1 : 0
  source                = "git::https://github.com/Coalfire-CF/terraform-azurerm-diagnostics?ref=v1.1.0"
  diag_log_analytics_id = azurerm_log_analytics_workspace.core_la.id
  resource_id           = module.tfstate_sa[0].id
  resource_type         = "sa"
}
