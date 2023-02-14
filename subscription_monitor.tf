# NOTE
# issue with provider and logs
# see - https://github.com/terraform-providers/terraform-provider-azurerm/issues/5673
# TLDR: some settings do not support retention policy in the provider and having that
# value would make TF reapply diag settings each time.
# Also the sub does not have a diag categories available for query. This is why the
# sub logs are stored in a var. And sub diag logs are slightly different than other logs.


module "diag_sub" {
  source                = "git@github.com:Coalfire-CF/ACE-Azure-Diagnostics.git?ref=v1.0.1"
  #git@github.com:Coalfire-CF/ACE-Azure-Diagnostics.git
  diag_log_analytics_id = azurerm_log_analytics_workspace.core-la.id
  resource_id           = "/subscriptions/${var.subscription_id}"
  resource_type         = "sub"
}
