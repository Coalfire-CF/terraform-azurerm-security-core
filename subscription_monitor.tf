# Activity Log to Log Analytics through the diagnostics module ("sub" type).
module "diag_sub" {
  count                 = var.enable_sub_logs ? 1 : 0
  source                = "git::https://github.com/Coalfire-CF/terraform-azurerm-diagnostics?ref=v3.0.0"
  diag_log_analytics_id = local.law_id
  resource_id           = "/subscriptions/${var.subscription_id}"
  resource_type         = "sub"
}
