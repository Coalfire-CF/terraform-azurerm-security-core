# # AAD Conditional Access Policy
# resource "azuread_conditional_access_policy" "default" {
#   display_name = "${var.resource_prefix}-conditional_access-ply"
#   state        = "enabledForReportingButNotEnforced" #change to enabled when ready

#   conditions {
#     client_app_types    = ["browser", "mobileAppsAndDesktopClients"]
#     sign_in_risk_levels = ["medium"]
#     user_risk_levels    = ["medium"]

#     applications {
#       included_applications = ["All"]
#     }

#     locations {
#       included_locations = ["All"]
#     }

#     platforms {
#       included_platforms = ["all"]
#     }

#     users {
#       included_users = ["All"]
#     }
#   }

#   grant_controls {
#     operator          = "AND"
#     built_in_controls = ["mfa"]
#   }

#   session_controls {
#     application_enforced_restrictions_enabled = true
#     cloud_app_security_policy = "monitorOnly"
#     sign_in_frequency_period = "hours"
#     sign_in_frequency = 4
#     persistent_browser_mode = "never"
#   }
# }

# AAD Logs
resource "azurerm_monitor_aad_diagnostic_setting" "aadlogs" {
  count = var.enable_aad_logs ? 1 : 0

  name                       = "AAD_Logs"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.core-la.id
  enabled_log {
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
