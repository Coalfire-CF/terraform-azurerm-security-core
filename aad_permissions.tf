resource "azuread_directory_role" "groups_administrator" {
  count        = var.enable_aad_permissions ? 1 : 0
  display_name = "Groups Administrator"
}

resource "azuread_directory_role" "app_owners" {
  count        = var.enable_aad_permissions ? 1 : 0
  display_name = "Application Administrator"
}

resource "azurerm_role_assignment" "assign_sub_contributor" {
  for_each = var.enable_aad_permissions ? toset(var.admin_principal_ids) : toset([])

  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "assign_sub_user_access" {
  for_each = var.enable_aad_permissions ? toset(var.admin_principal_ids) : toset([])

  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "User Access Administrator"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "assign_app_sub_contributor" {
  for_each             = { for entry in local.app_sub_user_mapping : "${substr(entry.user, -12, -1)}_${substr(entry.subscription_id, -12, -1)}" => entry if var.enable_aad_permissions }
  scope                = "/subscriptions/${each.value.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = each.value.user
}

resource "azurerm_role_assignment" "assign_app_sub_user_access" {
  for_each             = { for entry in local.app_sub_user_mapping : "${substr(entry.user, -12, -1)}_${substr(entry.subscription_id, -12, -1)}" => entry if var.enable_aad_permissions }
  scope                = "/subscriptions/${each.value.subscription_id}"
  role_definition_name = "User Access Administrator"
  principal_id         = each.value.user
}
