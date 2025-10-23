resource "azurerm_private_dns_zone" "default" {
  depends_on          = [azurerm_resource_group.core]
  for_each            = toset(local.private_dns_zones)
  name                = each.value
  resource_group_name = var.core_rg_name
  tags                = local.tags
}
