resource "azurerm_storage_account" "tf_state" {
  depends_on                        = [azurerm_resource_group.core]
  name                              = length("${local.storage_name_prefix}satfstate") <= 24 ? "${local.storage_name_prefix}satfstate" : "${var.location_abbreviation}mp${var.app_abbreviation}satfstate"
  resource_group_name               = azurerm_resource_group.core.name
  location                          = var.location
  account_tier                      = "Standard"
  account_replication_type          = "GRS"
  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  allow_nested_items_to_be_public   = false
  public_network_access_enabled     = true #controlled with firewall rules 
  infrastructure_encryption_enabled = true

  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      customer_managed_key # required by https://github.com/hashicorp/terraform-provider-azurerm/issues/16085
    ]
  }
  blob_properties {
    versioning_enabled = true
  }

  tags = merge({
    Function = "Storage"
    Plane    = "Core"
  }, var.global_tags, var.regional_tags)
}


resource "azurerm_role_assignment" "tstate_kv_crypto_user" {
  scope                = module.core_kv.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_storage_account.tf_state.identity[0].principal_id
}

resource "azurerm_storage_account_customer_managed_key" "enable_tstate_cmk" {
  storage_account_id = azurerm_storage_account.tf_state.id
  key_vault_id       = module.core_kv.key_vault_id
  key_name           = azurerm_key_vault_key.tstate-cmk.name
}


resource "azurerm_storage_container" "tf_state_lock" {
  name                  = "${var.location_abbreviation}${var.app_abbreviation}tfstatecontainer"
  storage_account_name  = azurerm_storage_account.tf_state.name
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "lifecycle_mgmt" {
  storage_account_id = azurerm_storage_account.tf_state.id

  rule {
    name    = "deleteAfter90"
    enabled = "true"
    filters {
      prefix_match = ["${var.location_abbreviation}${var.app_abbreviation}tfstatecontainer"]
      blob_types   = ["blockBlob"]
    }
    actions {
      version {
        delete_after_days_since_creation = 90
      }
    }
  }
}

module "diag_tf_state_sa" {
  source                = "github.com/Coalfire-CF/terraform-azurerm-diagnostics?ref=v1.0.0"
  diag_log_analytics_id = azurerm_log_analytics_workspace.core-la.id
  resource_id           = azurerm_storage_account.tf_state.id
  resource_type         = "sa"
}
