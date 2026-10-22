locals {
  storage_name_prefix        = replace(var.resource_prefix, "-", "")
  caller_tags                = merge(var.tags, var.global_tags, var.regional_tags)
  dns_tags                   = merge({ Function = "Networking", Plane = "Core" }, local.caller_tags)
  law_tags                   = merge({ Function = "SIEM", Plane = "Core" }, local.caller_tags)
  storage_tags               = merge({ Function = "Storage", Plane = "Management" }, local.caller_tags)
  law_id                     = var.create_log_analytics ? azurerm_log_analytics_workspace.core_la[0].id : var.diag_log_analytics_id
  create_law_queries_storage = var.create_log_analytics && var.create_law_queries_storage
  tfstate_container_name     = "${var.location_abbreviation}${var.app_abbreviation}tfstatecontainer"

  kv_zone_name = "privatelink.vaultcore.usgovcloudapi.net"
  sa_zone_name = "privatelink.blob.core.usgovcloudapi.net"
  kv_private_dns_zone_ids = length(var.kv_private_dns_zone_ids) > 0 ? var.kv_private_dns_zone_ids : (
    contains(local.private_dns_zones, local.kv_zone_name) ? [azurerm_private_dns_zone.default[local.kv_zone_name].id] : []
  )
  sa_private_dns_zone_id = var.sa_private_dns_zone_id != null ? var.sa_private_dns_zone_id : (
    contains(local.private_dns_zones, local.sa_zone_name) ? azurerm_private_dns_zone.default[local.sa_zone_name].id : null
  )

  # DNS
  regional_private_dns_zones = var.deploy_private_dns_zones ? {
    azure_kubernetes_service_management = [
      for location in [var.location, var.dr_location] :
      "privatelink.${location}.cx.aks.containerservice.azure.us"
    ]
    azure_kusto = [
      for location in [var.location, var.dr_location] :
      "privatelink.${location}.kusto.usgovcloudapi.net"
    ]
  } : {}

  private_dns_zones = var.deploy_private_dns_zones ? distinct(
    concat(
      var.azure_private_dns_zones,
      var.custom_private_dns_zones,
      flatten(values(local.regional_private_dns_zones))
    )
  ) : []

  # default resource names
  key_vault_name                   = var.key_vault_name != "default" ? var.key_vault_name : "${var.resource_prefix}-core-kv"
  tfstate_storage_account_name     = var.tfstate_storage_account_name != "default" ? var.tfstate_storage_account_name : length("${local.storage_name_prefix}satfstate") <= 24 ? "${local.storage_name_prefix}satfstate" : "${var.location_abbreviation}mp${var.app_abbreviation}satfstate"
  law_queries_storage_account_name = var.law_queries_storage_account_name != "default" ? var.law_queries_storage_account_name : length("${local.storage_name_prefix}salawqueries") <= 24 ? "${local.storage_name_prefix}salawqueries" : "${var.location_abbreviation}mp${var.app_abbreviation}salawqueries"
  log_analytics_workspace_name     = var.log_analytics_workspace_name != "default" ? var.log_analytics_workspace_name : "${var.resource_prefix}-la-1"
}
