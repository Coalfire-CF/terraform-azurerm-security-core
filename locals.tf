locals {
  storage_name_prefix = replace(var.resource_prefix, "-", "")
  enable_private_dns  = var.private_dns_zone_name != null ? true : false
  app_sub_user_mapping = distinct(flatten([for user in var.admin_principal_ids : [
    for app, sub in var.app_subscription_ids : {
      user            = user
      subscription_id = sub
    }
  ]]))
  tags = merge(var.regional_tags, var.global_tags, {
    Function = "Networking"
    Plane    = "Core"
  })
}