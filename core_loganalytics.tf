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
    Plane    = "Core"
  }, var.global_tags, var.regional_tags)

  depends_on = [
    azurerm_resource_group.core
  ]
}

# storage account for stored log analytics queries

#data "azurerm_client_config" "current" {}
resource "azurerm_storage_account" "law_queries" {
  name                              = length("${local.storage_name_prefix}salawqueries") <= 24 ? "${local.storage_name_prefix}salawqueries" : "${var.location_abbreviation}mp${var.app_abbreviation}salawqueries"
  resource_group_name               = azurerm_resource_group.core.name
  location                          = var.location
  account_tier                      = "Standard"
  account_replication_type          = "GRS"
  min_tls_version                   = "TLS1_2"
  enable_https_traffic_only         = true
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

  #removed for testing jun08-2023 -df
  # network_rules {
  #   default_action = "Deny"
  #   ip_rules       = var.ip_for_remote_access
  #   #virtual_network_subnet_ids = [module.core-vnet.vnet_subnets[2]]
  #   virtual_network_subnet_ids = var.ip_for_remote_access
  # }

  tags = merge({
    Function = "SIEM"
    Plane    = "Core"
  }, var.global_tags, var.regional_tags)
}


resource "azurerm_role_assignment" "law_queries_kv_crypto_user" {
  # for_each             = var.admin_principal_ids
  scope                = module.core_kv.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_storage_account.law_queries.identity.0.principal_id
}

resource "azurerm_storage_account_customer_managed_key" "enable_law_queries_cmk" {
  storage_account_id = azurerm_storage_account.law_queries.id
  key_vault_id       = module.core_kv.key_vault_id
  key_name           = azurerm_key_vault_key.law_queries-cmk.name
}


resource "azurerm_storage_container" "law_queries" {
  name                  = "law-queries"
  storage_account_name  = azurerm_storage_account.law_queries.name
  container_access_type = "private"
}

# resource "azurerm_storage_management_policy" "lifecycle_mgmt" {
#   storage_account_id = azurerm_storage_account.law_queries.id

#   rule {
#     name    = "deleteAfter90"
#     enabled = "true"
#     filters {
#       prefix_match = ["${var.location_abbreviation}${var.app_abbreviation}tfstatecontainer"]
#       blob_types   = ["blockBlob"]
#     }
#     actions {
#       version {
#         delete_after_days_since_creation = 90
#       }
#     }
#   }
# }

module "diag_la_queries_sa" {
  source                = "github.com/Coalfire-CF/ACE-Azure-Diagnostics"
  diag_log_analytics_id = azurerm_log_analytics_workspace.core-la.id
  resource_id           = azurerm_storage_account.law_queries.id
  resource_type         = "sa"
}

resource "azurerm_log_analytics_linked_storage_account" "law_queries" {
  data_source_type      = "Query"
  resource_group_name   = azurerm_resource_group.core.name
  workspace_resource_id = azurerm_log_analytics_workspace.core-la.id
  storage_account_ids   = [azurerm_storage_account.law_queries.id]
}

resource "azurerm_log_analytics_linked_storage_account" "law_alerts" {
  resource_group_name   = azurerm_resource_group.core.name
  workspace_resource_id = azurerm_log_analytics_workspace.core-la.id
  storage_account_ids   = [azurerm_storage_account.law_queries.id]
}
