resource "azurerm_private_dns_zone" "default" {
  for_each            = toset(local.private_dns_zones)
  name                = each.value
  resource_group_name = var.core_rg_name
  tags                = local.tags

  lifecycle {
    # ignore_changes = [number_of_record_sets]
  }
}
