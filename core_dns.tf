resource "azurerm_private_dns_zone" "default" {
  count               = local.enable_private_dns ? 1 : 0
  name                = var.private_dns_zone_name
  resource_group_name = var.core_rg_name
  tags                = local.tags


  lifecycle {
    ignore_changes = [number_of_record_sets]
  }
}


