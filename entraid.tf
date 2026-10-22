# Entra ID Logs
# Module-owned setting (D1): terraform-azurerm-diagnostics has no Entra ID tenant type.
# azurerm 5.10 enabled_log here takes only category (no category_group), so categories are listed.
# Source: https://learn.microsoft.com/en-us/entra/identity/monitoring-health/concept-diagnostic-settings-logs-options
# (updated 2026-05-12). The default sends all 18 categories of the Entra diagnostic settings
# section (R20). v2 sent 13. Added in v3: RiskyAgents, AgentRiskEvents (ID Protection for agents),
# NetworkAccessTrafficLogs, EnrichedOffice365AuditLogs, RemoteNetworkHealthLogs (Global Secure
# Access; they add no data unless it is in use). MicrosoftServicePrincipalSignInLogs is preview and
# high volume; it is kept because R20 asks for all categories. Remove it through var.aad_log_categories.
# CustomSecurityAttributeAuditLogs is not in this setting: the page says it is configured in the
# "Custom security attributes" section and needs the Attribute Log Administrator role. The caller owns it.
# Azure Government support is not verified for any category. A category the tenant does not expose
# fails the apply; remove it through var.aad_log_categories.
# Creating this setting needs the Security Administrator role in the tenant.
resource "azurerm_monitor_aad_diagnostic_setting" "aadlogs" {
  count = var.enable_aad_logs ? 1 : 0

  name                       = "AAD_Logs"
  log_analytics_workspace_id = local.law_id

  dynamic "enabled_log" {
    for_each = toset(var.aad_log_categories)
    content {
      category = enabled_log.value
    }
  }
}
