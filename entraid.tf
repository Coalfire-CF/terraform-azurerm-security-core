# Entra ID Logs
resource "azurerm_monitor_aad_diagnostic_setting" "aadlogs" {
  count = var.enable_aad_logs ? 1 : 0

  name                       = "AAD_Logs"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.core_la[0].id
  enabled_log {
    category = "SignInLogs"
  }
  enabled_log {
    category = "AuditLogs"
  }
  enabled_log {
    category = "NonInteractiveUserSignInLogs"
  }
  enabled_log {
    category = "ServicePrincipalSignInLogs"
  }
  enabled_log {
    category = "ManagedIdentitySignInLogs"
  }
  enabled_log {
    category = "ADFSSignInLogs"
  }
  enabled_log {
    category = "RiskyUsers"
  }
  enabled_log {
    category = "UserRiskEvents"
  }
  enabled_log {
    category = "RiskyServicePrincipals"
  }
  enabled_log {
    category = "ServicePrincipalRiskEvents"
  }
  enabled_log {
    category = "MicrosoftGraphActivityLogs"
  }
  enabled_log {
    category = "MicrosoftServicePrincipalSignInLogs"
  }
  enabled_log {
    category = "ProvisioningLogs"
  }
}
