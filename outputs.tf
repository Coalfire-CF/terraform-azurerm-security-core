output "core_rg_name" {
  value       = azurerm_resource_group.core.name
  description = "Name of the core resource group"
}

output "core_la_id" {
  value       = azurerm_log_analytics_workspace.core_la[0].id
  description = "Value of the core log analytics workspace id"
}

output "core_la_primaryKey" {
  value       = azurerm_log_analytics_workspace.core_la[0].primary_shared_key
  description = "Value of the core log analytics workspace primary key"
}

output "core_la_secondaryKey" {
  value       = azurerm_log_analytics_workspace.core_la[0].secondary_shared_key
  description = "Value of the core log analytics workspace secondary key"
}

output "core_la_workspace_id" {
  value       = azurerm_log_analytics_workspace.core_la[0].workspace_id
  description = "Value of the core log analytics workspace id"
}

output "core_la_workspace_name" {
  value       = azurerm_log_analytics_workspace.core_la[0].name
  description = "Value of the core log analytics workspace name"
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

output "ad_cmk_resource_id" {
  value       = try(module.ad_cmk[0].key_resource_id, null)
  description = "Active Directory CMK Key Resource ID"
}

output "ad_cmk_name" {
  value       = try(module.ad_cmk[0].key_name, null)
  description = "Active Directory CMK Key Name"
}

output "ars_cmk_id" {
  value       = try(module.ars_cmk[0].key_id, null)
  description = "Azure Recovery Services CMK Key ID"
}

output "ars_cmk_resource_id" {
  value       = try(module.ars_cmk[0].key_resource_id, null)
  description = "Azure Recovery Services CMK Key Resource ID"
}

output "ars_cmk_name" {
  value       = try(module.ars_cmk[0].key_name, null)
  description = "Azure Recovery Services CMK Key Name"
}

output "flowlog_cmk_id" {
  value       = try(module.flowlog_cmk[0].key_id, null)
  description = "Flowlogs CMK Key ID"
}

output "flowlog_cmk_resource_id" {
  value       = try(module.flowlog_cmk[0].key_resource_id, null)
  description = "Flowlogs CMK Key Resource ID"
}

output "flowlog_cmk_name" {
  value       = try(module.flowlog_cmk[0].key_name, null)
  description = "Flowlogs CMK Key Name"
}

output "install_cmk_id" {
  value       = try(module.install_cmk[0].key_id, null)
  description = "Installs CMK Key ID"
}

output "install_cmk_resource_id" {
  value       = try(module.install_cmk[0].key_resource_id, null)
  description = "Installs CMK Key Resource ID"
}

output "install_cmk_name" {
  value       = try(module.install_cmk[0].key_name, null)
  description = "Installs CMK Key Name"
}

output "law_queries_cmk_id" {
  value       = try(module.law_queries_cmk[0].key_id, null)
  description = "Log Analytics Workspace Queries CMK Key ID"
}

output "law_queries_cmk_resource_id" {
  value       = try(module.law_queries_cmk[0].key_resource_id, null)
  description = "Log Analytics Workspace Queries CMK Key Resource ID"
}

output "law_queries_cmk_name" {
  value       = try(module.law_queries_cmk[0].key_name, null)
  description = "Log Analytics Workspace Queries CMK Key Name"
}

output "tstate_cmk_id" {
  value       = try(module.tstate_cmk[0].key_id, null)
  description = "Terraform State CMK Key ID"
}

output "tstate_cmk_resource_id" {
  value       = try(module.tstate_cmk[0].key_resource_id, null)
  description = "Terraform State CMK Key Resource ID"
}

output "tstate_cmk_name" {
  value       = try(module.tstate_cmk[0].key_name, null)
  description = "Terraform State CMK Key Name"
}

output "cloudshell_cmk_id" {
  value       = try(module.cloudshell_cmk[0].key_id, null)
  description = "Cloudshell CMK Key ID"
}

output "cloudshell_cmk_resource_id" {
  value       = try(module.cloudshell_cmk[0].key_resource_id, null)
  description = "Cloudshell CMK Key Resource ID"
}

output "cloudshell_cmk_name" {
  value       = try(module.cloudshell_cmk[0].key_name, null)
  description = "Cloudshell CMK Key Name"
}

output "docs_cmk_id" {
  value       = try(module.docs_cmk[0].key_id, null)
  description = "Docs CMK Key ID"
}

output "docs_cmk_resource_id" {
  value       = try(module.docs_cmk[0].key_resource_id, null)
  description = "Docs CMK Key Resource ID"
}

output "docs_cmk_name" {
  value       = try(module.docs_cmk[0].key_name, null)
  description = "Docs CMK Key Name"
}

output "avd_cmk_id" {
  value       = try(module.avd_cmk[0].key_id, null)
  description = "Azure Virtual Desktop CMK Key ID"
}

output "avd_cmk_resource_id" {
  value       = try(module.avd_cmk[0].key_resource_id, null)
  description = "Azure Virtual Desktop CMK Key Resource ID"
}

output "avd_cmk_name" {
  value       = try(module.avd_cmk[0].key_name, null)
  description = "Azure Virtual Desktop CMK Key Name"
}

output "vm_disk_cmk_id" {
  value       = try(module.vm_disk_cmk[0].key_id, null)
  description = "VM Disk CMK Key ID"
}

output "vm_disk_cmk_resource_id" {
  value       = try(module.vm_disk_cmk[0].key_resource_id, null)
  description = "VM Disk CMK Key Resource ID"
}

output "vm_disk_cmk_name" {
  value       = try(module.vm_disk_cmk[0].key_name, null)
  description = "VM Disk CMK Key Name"
}

output "vmdiag_cmk_id" {
  value       = try(module.vmdiag_cmk[0].key_id, null)
  description = "VMDiag CMK Key ID"
}

output "vmdiag_cmk_resource_id" {
  value       = try(module.vmdiag_cmk[0].key_resource_id, null)
  description = "VMDiag CMK Key Resource ID"
}

output "vmdiag_cmk_name" {
  value       = try(module.vmdiag_cmk[0].key_name, null)
  description = "VMDiag CMK Key Name"
}

output "aks_node_cmk_id" {
  value       = try(module.aks_node_cmk[0].key_id, null)
  description = "AKS Node CMK Key ID"
}

output "aks_node_cmk_resource_id" {
  value       = try(module.aks_node_cmk[0].key_resource_id, null)
  description = "AKS Node CMK Key Resource ID"
}

output "aks_node_cmk_name" {
  value       = try(module.aks_node_cmk[0].key_name, null)
  description = "AKS Node CMK Key Name"
}

output "core_xadm_ssh_public_key" {
  value       = trimspace(tls_private_key.xadm.public_key_openssh)
  description = "Value of the SSH public key for xadm"
  sensitive   = true
}

output "core_private_dns_zone_id" {
  value       = values(azurerm_private_dns_zone.default)[*].id
  description = "Private DNS Zone IDs"
}

output "core_private_dns_zones" {
  value       = values(azurerm_private_dns_zone.default)[*].name
  description = "Private DNS Zone names"
}

output "core_map_private_dns_zone_ids" {
  description = "Map of Private DNS zone names to their resource IDs"
  value = {
    for zone_name, zone in azurerm_private_dns_zone.default :
    zone_name => zone.id
  }
}

