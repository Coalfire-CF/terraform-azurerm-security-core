output "core_rg_name" {
  value = azurerm_resource_group.core.name
}

output "core_la_id" {
  value = azurerm_log_analytics_workspace.core-la.id
}

output "core_la_primaryKey" {
  value = azurerm_log_analytics_workspace.core-la.primary_shared_key
}

output "core_la_secondaryKey" {
  value = azurerm_log_analytics_workspace.core-la.secondary_shared_key
}

output "core_la_workspace_id" {
  value = azurerm_log_analytics_workspace.core-la.workspace_id
}

output "core_la_workspace_name" {
  value = azurerm_log_analytics_workspace.core-la.name
}

output "core_kv_name" {
  value = module.core_kv.key_vault_name
}

output "core_kv_id" {
  value = module.core_kv.key_vault_id
}

output "ad-cmk_id" {
  value = azurerm_key_vault_key.ad-cmk.id
}

output "ars-cmk_id" {
  value = azurerm_key_vault_key.ars-cmk.id
}

output "flowlog-cmk_id" {
  value = azurerm_key_vault_key.flowlog-cmk.id
}

output "install-cmk_id" {
  value = azurerm_key_vault_key.install-cmk.id
}

output "law_queries-cmk_id" {
  value = azurerm_key_vault_key.law_queries-cmk.id
}

output "tstate-cmk_id" {
  value = azurerm_key_vault_key.tstate-cmk.id
}

output "cloudshell-cmk_id" {
  value = azurerm_key_vault_key.cloudshell-cmk.id
}

output "docs-cmk_id" {
  value = azurerm_key_vault_key.docs-cmk.id
}

output "avd-cmk_id" {
  value = azurerm_key_vault_key.avd-cmk.id
}

# output "core_private_dns_zone_name" {
#   value = local.enable_private_dns ? azurerm_private_dns_zone.default.0.name : null
# }

output "core_private_dns_zone_id" {
  #value = local.enable_private_dns ? azurerm_private_dns_zone.default.0.id : null
  value = azurerm_private_dns_zone.default.0.id
}
output "core_private_dns_zones" {
  # value = { for zone in azurerm_private_dns_zone.default : zone.name => zone.id }
  value = azurerm_private_dns_zone.default.0.name
}

output "core_xadm_ssh_public_key" {
  value = trimspace(tls_private_key.xadm.public_key_openssh)
}
