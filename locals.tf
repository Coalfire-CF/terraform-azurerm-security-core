locals {
  storage_name_prefix = replace(var.resource_prefix, "-", "")
  app_sub_user_mapping = distinct(flatten([for user in var.admin_principal_ids : [
    for app, sub in var.app_subscription_ids : {
      user            = user
      subscription_id = sub
    }
  ]]))
  tags = merge(var.regional_tags, var.global_tags, {
    Function = "Networking"
    Plane    = "Core"
  })

  # DNS
  regional_private_dns_zones = {
    azure_kubernetes_service_management = [
      for location in [var.location, var.dr_location] :
      "privatelink.${location}.cx.aks.containerservice.azure.us"
    ]
    azure_kusto = [
      for location in [var.location, var.dr_location] :
      "privatelink.${location}.kusto.usgovcloudapi.net"
    ]
  }
  private_dns_zones = distinct(concat(var.azure_private_dns_zones, var.custom_private_dns_zones, flatten(values(local.regional_private_dns_zones))))


  # default resource names
  key_vault_name                   = var.key_vault_name != "default" ? var.key_vault_name : "${var.resource_prefix}-core-kv"
  tfstate_storage_account_name     = var.tfstate_storage_account_name != "default" ? var.tfstate_storage_account_name : length("${local.storage_name_prefix}satfstate") <= 24 ? "${local.storage_name_prefix}satfstate" : "${var.location_abbreviation}mp${var.app_abbreviation}satfstate"
  law_queries_storage_account_name = var.law_queries_storage_account_name != "default" ? var.law_queries_storage_account_name : length("${local.storage_name_prefix}salawqueries") <= 24 ? "${local.storage_name_prefix}salawqueries" : "${var.location_abbreviation}mp${var.app_abbreviation}salawqueries"
  log_analytics_workspace_name     = var.log_analytics_workspace_name != "default" ? var.loganalytics_workspace_name : "${var.resource_prefix}-la-1"
}
