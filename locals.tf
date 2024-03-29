locals {
  storage_name_prefix = replace(var.resource_prefix, "-", "")
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

  # DNS
  regional_private_dns_zones = {
    azure_kubernetes_service_management = [
      for location in [var.location, var.dr_location] :
      "privatelink.${location}.cx.aks.containerservice.azure.us"
    ]
    azure_kusto = [
      for location in [var.location, var.dr_location] :
      "privatelink.${location}.kusto.usgovcloudapi.net"
    ]
  }
  private_dns_zones = distinct(concat(var.azure_private_dns_zones, var.custom_private_dns_zones, flatten(values(local.regional_private_dns_zones))))
}
