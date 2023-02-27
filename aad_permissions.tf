resource "azuread_directory_role" "groups_administrator" {
  display_name = "Groups administrator"
}

resource "azuread_directory_role_assignment" "assign_groups_administrator" {
  for_each         = var.admin_principal_ids
  role_object_id   = azuread_directory_role.groups_administrator.object_id
  member_object_id = each.key
}

resource "azuread_directory_role" "app_owners" {
  display_name = "Application administrator"
}

resource "azuread_directory_role_assignment" "assign_app_owners" {
  for_each         = var.admin_principal_ids
  role_object_id   = azuread_directory_role.app_owners.object_id
  member_object_id = each.key
}

resource "azurerm_role_assignment" "assign_sub_contributor" {
  for_each             = var.admin_principal_ids
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "assign_sub_user_access" {
  for_each             = var.admin_principal_ids
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "User Access Administrator"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "assign_app_sub_contributor" {
  for_each             = { for entry in local.app_sub_user_mapping : "${substr(entry.user, -12, -1)}_${substr(entry.subscription_id, -12, -1)}" => entry }
  scope                = "/subscriptions/${each.value.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = each.value.user
}

resource "azurerm_role_assignment" "assign_app_sub_user_access" {
  for_each             = { for entry in local.app_sub_user_mapping : "${substr(entry.user, -12, -1)}_${substr(entry.subscription_id, -12, -1)}" => entry }
  scope                = "/subscriptions/${each.value.subscription_id}"
  role_definition_name = "User Access Administrator"
  principal_id         = each.value.user
}
