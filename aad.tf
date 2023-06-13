# AAD Logs
resource "azurerm_monitor_aad_diagnostic_setting" "aadlogs" {
  count = var.enable_aad_logs ? 1 : 0

  name                       = "AAD_Logs"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.core-la.id
  log {
    category = "SignInLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 365
    }
  }
  log {
    category = "AuditLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 365
    }
  }
  log {
    category = "NonInteractiveUserSignInLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 365
    }
  }
  log {
    category = "ServicePrincipalSignInLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 365
    }
  }
  log {
    category = "ManagedIdentitySignInLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 365
    }
  }
  # not supported on Gov Cloud
  # log {
  #   category = "ProvisioningLogs"
  #   enabled  = true
  #   retention_policy {
  #     enabled = true
  #     days    = 365
  #   }
  # }
  log {
    category = "ADFSSignInLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 365
    }
  }
  log {
    category = "RiskyUsers"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 365
    }
  }
  log {
    category = "UserRiskEvents"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "RiskyServicePrincipals"
    enabled  = false
    retention_policy {
      enabled = false
      days    = 0
    }
  }
  log {
    category = "ServicePrincipalRiskEvents"
    enabled  = false
    retention_policy {
      enabled = false
      days    = 0
    }
  }
}
