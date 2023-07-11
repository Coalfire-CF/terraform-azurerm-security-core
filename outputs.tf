output "core_rg_name" {
  value       = azurerm_resource_group.core.name
  description = "Name of the core resource group"
}

output "core_la_id" {
  value       = azurerm_log_analytics_workspace.core-la.id
  description = "value of the core log analytics workspace id"
}

output "core_la_primaryKey" {
  value       = azurerm_log_analytics_workspace.core-la.primary_shared_key
  description = "value of the core log analytics workspace primary key"
}

output "core_la_secondaryKey" {
  value       = azurerm_log_analytics_workspace.core-la.secondary_shared_key
  description = "value of the core log analytics workspace secondary key"
}

output "core_la_workspace_id" {
  value       = azurerm_log_analytics_workspace.core-la.workspace_id
  description = "value of the core log analytics workspace id"
}

output "core_la_workspace_name" {
  value       = azurerm_log_analytics_workspace.core-la.name
  description = "value of the core log analytics workspace name"
}

output "core_kv_name" {
  value       = module.core_kv.key_vault_name
  description = "Name of the Core Key vault"
}

output "core_kv_id" {
  value       = module.core_kv.key_vault_id
  description = "Value of the Core Key Vault ID"
}

output "ad-cmk_id" {
  value       = azurerm_key_vault_key.ad-cmk.id
  description = "AD SA CMK ID"
}

output "ars-cmk_id" {
  value       = azurerm_key_vault_key.ars-cmk.id
  description = "Azure Recovery Services SA CMK ID"
}

output "flowlog-cmk_id" {
  value       = azurerm_key_vault_key.flowlog-cmk.id
  description = "Flowlogs SA CMK ID"
}

output "install-cmk_id" {
  value       = azurerm_key_vault_key.install-cmk.id
  description = "Installs SA CMK ID"
}

output "law_queries-cmk_id" {
  value       = azurerm_key_vault_key.law_queries-cmk.id
  description = "Log Analytics Workspace Queries SA CMK ID"
}

output "tstate-cmk_id" {
  value       = azurerm_key_vault_key.tstate-cmk.id
  description = "Terraform State SA CMK ID"
}

output "cloudshell-cmk_id" {
  value       = azurerm_key_vault_key.cloudshell-cmk.id
  description = "Cloudshell SA CMK ID"
}

output "docs-cmk_id" {
  value       = azurerm_key_vault_key.docs-cmk.id
  description = "Docs SA CMK ID"
}

output "avd-cmk_id" {
  value       = azurerm_key_vault_key.avd-cmk.id
  description = "Azure Virtual Desktop CMK ID"
}

output "core_xadm_ssh_public_key" {
  value       = trimspace(tls_private_key.xadm.public_key_openssh)
  description = "Value of the SSH public key for xadm"
}

# output "core_private_dns_zone_name" {
#   value = local.enable_private_dns ? azurerm_private_dns_zone.default.0.name : null
# }

output "core_private_dns_zone_id" {
  #value = local.enable_private_dns ? azurerm_private_dns_zone.default.0.id : null
  # value = azurerm_private_dns_zone.default[each.key].id
  value       = values(azurerm_private_dns_zone.default).*.id
  description = "Private DNS Zone IDs"
}

# sample
# output "core_private_dns_zone_id" {
#   value = {
#     for k, bd in mso_schema_template_bd.bd : k => bd.name
#   }
# }


output "core_private_dns_zones" {
  # value = { for zone in azurerm_private_dns_zone.default : zone.name => zone.id }
  #  value = azurerm_private_dns_zone.default[each.key].name
  value       = values(azurerm_private_dns_zone.default).*.name
  description = "Private DNS Zone names"
}
