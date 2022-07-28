resource "azurerm_role_assignment" "core_kv_administrator" {
  for_each             = var.admin_principal_ids
  scope                = module.core_kv.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.key
}

data "azurerm_subscription" "primary" {
}
# resource "azurerm_role_assignment" "core_user_administrator" {
#   for_each             = var.admin_principal_ids
#   scope                = data.azurerm_subscription.primary.id
#   role_definition_name = "User Access Administrator"
#   principal_id         = each.key
# }
