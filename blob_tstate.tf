data "azurerm_client_config" "current" {}
resource "azurerm_storage_account" "tf_state" {
  name                            = length("${local.storage_name_prefix}satfstate") <= 24 ? "${local.storage_name_prefix}satfstate" : "${var.location_abbreviation}mp${var.app_abbreviation}satfstate"
  resource_group_name             = azurerm_resource_group.core.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = false

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

  network_rules {
    default_action = "Deny"
    ip_rules       = var.ip_for_remote_access
    #virtual_network_subnet_ids = [module.core-vnet.vnet_subnets[2]]
    virtual_network_subnet_ids = var.ip_for_remote_access
  }

  tags = merge({
    Function = "Storage"
    Plane    = "Core"
  }, var.global_tags, var.regional_tags)
}


resource "azurerm_role_assignment" "tstate_kv_crypto_user" {
  # for_each             = var.admin_principal_ids
  scope                = module.core_kv.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_storage_account.tf_state.identity.0.principal_id
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
  source                = "github.com/Coalfire-CF/ACE-Azure-Diagnostics"
  diag_log_analytics_id = azurerm_log_analytics_workspace.core-la.id
  resource_id           = azurerm_storage_account.tf_state.id
  resource_type         = "sa"
}
