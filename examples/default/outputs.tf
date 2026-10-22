output "core_kv_id" {
  value       = module.core.core_kv_id
  description = "Core Key Vault ID"
}

output "core_la_id" {
  value       = module.core.core_la_id
  description = "Core Log Analytics workspace ID"
}

output "core_rg_name" {
  value       = module.core.core_rg_name
  description = "Core resource group name"
}
