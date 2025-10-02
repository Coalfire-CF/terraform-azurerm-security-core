data "azuread_directory_roles" "default" {}

locals {
 ad_roles = { for role in data.azuread_directory_roles.default.roles : role.display_name => role.template_id }
}

resource "azuread_directory_role" "groups_administrator" {
  count = var.enable_aad_permissions ? 1 : 0
  display_name = "Groups Administrator"
}

resource "azuread_directory_role_assignment" "assign_groups_administrator" {
  for_each = var.enable_aad_permissions ? toset(var.admin_principal_ids) : []

  role_id             = local.ad_roles["Groups Administrator"]
  principal_object_id = each.value
  depends_on          = [azuread_directory_role.groups_administrator]
}

resource "azuread_directory_role" "app_owners" {
  count = var.enable_aad_permissions ? 1 : 0
  display_name = "Application Administrator"
}

resource "azuread_directory_role_assignment" "assign_app_owners" {
  for_each = var.enable_aad_permissions ? toset(var.admin_principal_ids) : []

  role_id             = local.ad_roles["Application Administrator"]
  principal_object_id = each.value
  depends_on          = [azuread_directory_role.app_owners]
}

resource "azurerm_role_assignment" "assign_sub_contributor" {
  for_each = var.enable_aad_permissions ? toset(var.admin_principal_ids) : []

  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "assign_sub_user_access" {
  for_each = var.enable_aad_permissions ? toset(var.admin_principal_ids) : []

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
