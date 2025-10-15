output "core_rg_name" {
  value       = azurerm_resource_group.core.name
  description = "Name of the core resource group"
}

output "core_la_id" {
  value       = azurerm_log_analytics_workspace.core_la.id
  description = "value of the core log analytics workspace id"
}

output "core_la_primaryKey" {
  value       = azurerm_log_analytics_workspace.core_la.primary_shared_key
  description = "value of the core log analytics workspace primary key"
}

output "core_la_secondaryKey" {
  value       = azurerm_log_analytics_workspace.core_la.secondary_shared_key
  description = "value of the core log analytics workspace secondary key"
}

output "core_la_workspace_id" {
  value       = azurerm_log_analytics_workspace.core_la.workspace_id
  description = "value of the core log analytics workspace id"
}

output "core_la_workspace_name" {
  value       = azurerm_log_analytics_workspace.core_la.name
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

output "ad_cmk_id" {
  value       = try(module.ad_cmk[0].key_id, null)
  description = "Active Directory CMK Key ID"
}

output "ad_cmk_name" {
  value       = try(module.ad_cmk[0].key_name, null)
  description = "Active Directory CMK Key Name"
}

output "ars_cmk_id" {
  value       = try(module.ars_cmk[0].key_id, null)
  description = "Azure Recovery Services CMK Key ID"
}

output "ars_cmk_name" {
  value       = try(module.ars_cmk[0].key_name, null)
  description = "Azure Recovery Services CMK Key Name"
}

output "flowlog_cmk_id" {
  value       = try(module.flowlog_cmk[0].key_id, null)
  description = "Flowlogs CMK Key ID"
}

output "flowlog_cmk_name" {
  value       = try(module.flowlog_cmk[0].key_name, null)
  description = "Flowlogs CMK Key Name"
}

output "install_cmk_id" {
  value       = try(module.install_cmk[0].key_id, null)
  description = "Installs CMK Key ID"
}

output "install_cmk_name" {
  value       = try(module.install_cmk[0].key_name, null)
  description = "Installs CMK Key Name"
}

output "law_queries_cmk_id" {
  value       = try(module.law_queries_cmk[0].key_id, null)
  description = "Log Analytics Workspace Queries CMK Key ID"
}

output "law_queries_cmk_name" {
  value       = try(module.law_queries_cmk[0].key_name, null)
  description = "Log Analytics Workspace Queries CMK Key Name"
}

output "tstate_cmk_id" {
  value       = try(module.tstate_cmk[0].key_id, null)
  description = "Terraform State CMK Key ID"
}

output "tstate_cmk_name" {
  value       = try(module.tstate_cmk[0].key_name, null)
  description = "Terraform State CMK Key Name"
}

output "cloudshell_cmk_id" {
  value       = try(module.cloudshell_cmk[0].key_id, null)
  description = "Cloudshell CMK Key ID"
}

output "cloudshell_cmk_name" {
  value       = try(module.cloudshell_cmk[0].key_name, null)
  description = "Cloudshell CMK Key Name"
}

output "docs_cmk_id" {
  value       = try(module.docs_cmk[0].key_id, null)
  description = "Docs CMK Key ID"
}

output "docs_cmk_name" {
  value       = try(module.docs_cmk[0].key_name, null)
  description = "Docs CMK Key Name"
}

output "avd_cmk_id" {
  value       = try(module.avd_cmk[0].key_id, null)
  description = "Azure Virtual Desktop CMK Key ID"
}

output "avd_cmk_name" {
  value       = try(module.avd_cmk[0].key_name, null)
  description = "Azure Virtual Desktop CMK Key Name"
}

output "core_xadm_ssh_public_key" {
  value       = trimspace(tls_private_key.xadm.public_key_openssh)
  description = "Value of the SSH public key for xadm"
  sensitive = true
}

output "core_private_dns_zone_id" {
  value       = values(azurerm_private_dns_zone.default)[*].id
  description = "Private DNS Zone IDs"
}

output "core_private_dns_zones" {
  value       = values(azurerm_private_dns_zone.default)[*].name
  description = "Private DNS Zone names"
}
