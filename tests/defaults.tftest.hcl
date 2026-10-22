# Plan-only tests. The resource group has prevent_destroy, so an apply-mode test could not tear down.
# random, tls and time run unmocked; they are local and need no credentials.

mock_provider "azurerm" {
  mock_data "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_groups = ["allLogs"]
      log_category_types  = ["AuditEvent"]
      metrics             = ["AllMetrics"]
    }
  }
}

variables {
  subscription_id       = "00000000-0000-0000-0000-000000000000"
  tenant_id             = "00000000-0000-0000-0000-000000000000"
  resource_prefix       = "tst-usgv"
  location              = "usgovvirginia"
  location_abbreviation = "usgv"
  app_abbreviation      = "cf"
  admin_principal_ids   = ["00000000-0000-0000-0000-000000000001"]
  tags                  = { Owner = "test" }
  global_tags           = {}
  regional_tags         = {}
}

run "defaults_are_secure" {
  command = plan

  assert {
    condition     = azurerm_log_analytics_workspace.core_la[0].internet_ingestion_access_type == "Disabled"
    error_message = "LAW internet ingestion must default to Disabled."
  }
  assert {
    condition     = azurerm_log_analytics_workspace.core_la[0].internet_query_access_type == "Disabled"
    error_message = "LAW internet query must default to Disabled."
  }
  assert {
    condition     = azurerm_log_analytics_workspace.core_la[0].local_authentication_enabled == false
    error_message = "LAW local authentication must default to false."
  }
  assert {
    condition     = azurerm_key_vault_secret.xadm_ssh_priv.value == null
    error_message = "The private key must go only through value_wo."
  }
  assert {
    condition     = time_offset.ssh_secret_expiry.offset_days == 365
    error_message = "SSH secret expiry must default to 365 days."
  }
  assert {
    condition     = azurerm_resource_group.core.tags["Owner"] == "test"
    error_message = "The resource group must carry caller tags."
  }
  assert {
    condition     = azurerm_key_vault_secret.xadm_ssh_pub.tags["Owner"] == "test"
    error_message = "The SSH secrets must carry caller tags."
  }
  assert {
    condition     = length(module.tfstate_sa) == 1 && length(module.law_queries_sa) == 1
    error_message = "Both storage accounts must be planned by default."
  }
  assert {
    condition     = contains(keys(module.tfstate_sa[0].container_names), "usgvcftfstatecontainer")
    error_message = "The state container must be created inside storage-account."
  }
  assert {
    condition     = output.tfstate_container_name == "usgvcftfstatecontainer"
    error_message = "tfstate_container_name output must keep the v2 name."
  }
  assert {
    condition     = contains(keys(module.law_queries_sa[0].container_names), "law-queries")
    error_message = "The law-queries container must be created inside storage-account."
  }
  assert {
    condition     = length(azurerm_monitor_aad_diagnostic_setting.aadlogs[0].enabled_log) == 18
    error_message = "The Entra setting must send all 18 categories by default."
  }
  assert {
    condition     = contains([for l in azurerm_monitor_aad_diagnostic_setting.aadlogs[0].enabled_log : l.category], "RiskyAgents")
    error_message = "RiskyAgents must be in the default Entra categories."
  }
  assert {
    condition     = contains([for l in azurerm_monitor_aad_diagnostic_setting.aadlogs[0].enabled_log : l.category], "AgentRiskEvents")
    error_message = "AgentRiskEvents must be in the default Entra categories."
  }
  assert {
    condition = (
      length(module.ars_cmk) + length(module.flowlog_cmk) + length(module.install_cmk) +
      length(module.cloudshell_cmk) + length(module.docs_cmk) + length(module.vm_disk_cmk) +
      length(module.vmdiag_cmk) + length(module.ad_cmk) + length(module.avd_cmk) + length(module.aks_node_cmk)
    ) == 0
    error_message = "No CMK keys may be created by default (R12)."
  }

  # Interface default pins. Child-side defaults are asserted in key-vault v3 and storage-account v3 tests.
  assert {
    condition     = var.sa_public_network_access == "Disabled"
    error_message = "sa_public_network_access must default to Disabled."
  }
  assert {
    condition     = var.kv_public_network_access_enabled == false
    error_message = "kv_public_network_access_enabled must default to false."
  }
  assert {
    condition     = var.kms_key_vault_network_access == "Private"
    error_message = "kms_key_vault_network_access must default to Private."
  }
  assert {
    condition     = var.enable_customer_managed_key == false
    error_message = "enable_customer_managed_key must default to false."
  }
}

run "external_workspace" {
  command = plan

  variables {
    create_log_analytics  = false
    diag_log_analytics_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/ext"
  }

  assert {
    condition     = length(azurerm_log_analytics_workspace.core_la) == 0
    error_message = "No workspace may be created when create_log_analytics is false."
  }
  assert {
    condition     = length(module.law_queries_sa) == 0
    error_message = "LAW query storage needs the module's own workspace."
  }
  assert {
    condition     = length(azurerm_log_analytics_linked_storage_account.law_queries) == 0
    error_message = "Linked storage needs the module's own workspace."
  }
  assert {
    condition     = azurerm_monitor_aad_diagnostic_setting.aadlogs[0].log_analytics_workspace_id == var.diag_log_analytics_id
    error_message = "The Entra setting must use the external workspace."
  }
}

run "missing_workspace_rejected" {
  command = plan

  variables {
    create_log_analytics = false
  }

  expect_failures = [var.diag_log_analytics_id]
}

run "kv_network_access_rejects_unknown" {
  command = plan

  variables {
    kms_key_vault_network_access = "Open"
  }

  expect_failures = [var.kms_key_vault_network_access]
}

run "sa_public_network_access_rejects_unknown" {
  command = plan

  variables {
    sa_public_network_access = "true"
  }

  expect_failures = [var.sa_public_network_access]
}

run "key_vault_name_too_long" {
  command = plan

  variables {
    key_vault_name = "abcdefghijklmnopqrstuv"
  }

  expect_failures = [var.key_vault_name]
}

run "validation_accepts_allowed_values" {
  command = plan

  variables {
    kms_key_vault_network_access = "Public"
    sa_public_network_access     = "Enabled"
    key_vault_name               = "abcdefghijklmnopqrstu"
    ip_for_remote_access         = ["203.0.113.1", "198.51.100.0/24"]
    cidrs_for_remote_access      = ["203.0.113.0/24"]
    key_size                     = 2048
    location_abbreviation        = "usgv2"
    app_abbreviation             = "cf1"
  }

  assert {
    condition     = var.key_size == 2048 && var.sa_public_network_access == "Enabled"
    error_message = "Allowed values must be accepted."
  }
}

run "ip_rules_reject_slash_32" {
  command = plan

  variables {
    ip_for_remote_access = ["203.0.113.1/32"]
  }

  expect_failures = [var.ip_for_remote_access]
}

run "cmk_opt_in_plans" {
  command = plan

  variables {
    enable_customer_managed_key = true
    create_ars_cmk              = true
  }

  assert {
    condition     = length(module.tfstate_sa) == 1 && length(module.law_queries_sa) == 1
    error_message = "Both storage accounts must plan with CMK on."
  }
  assert {
    condition     = length(module.ars_cmk) == 1
    error_message = "create_ars_cmk must create the ARS key."
  }
}

run "tfstate_storage_off" {
  command = plan

  variables {
    create_tfstate_storage = false
  }

  assert {
    condition     = length(module.tfstate_sa) == 0
    error_message = "No state storage when create_tfstate_storage is false."
  }
  assert {
    condition     = output.tfstate_container_name == null
    error_message = "tfstate_container_name must be null when state storage is off."
  }
}

run "aad_categories_subset" {
  command = plan

  variables {
    aad_log_categories = ["AuditLogs", "SignInLogs"]
  }

  assert {
    condition     = length(azurerm_monitor_aad_diagnostic_setting.aadlogs[0].enabled_log) == 2
    error_message = "A caller must be able to send a subset of categories."
  }
}

run "aad_categories_custom_security_rejected" {
  command = plan

  variables {
    aad_log_categories = ["AuditLogs", "CustomSecurityAttributeAuditLogs"]
  }

  expect_failures = [var.aad_log_categories]
}

run "aad_categories_empty_rejected" {
  command = plan

  variables {
    aad_log_categories = []
  }

  expect_failures = [var.aad_log_categories]
}

run "private_endpoints_module_zones" {
  command = plan

  # Makes the zone IDs known at plan so the zone-ID locals can be compared.
  override_resource {
    target          = azurerm_private_dns_zone.default
    override_during = plan
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/core-rg-1/providers/Microsoft.Network/privateDnsZones/mocked"
    }
  }

  variables {
    kv_private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
    sa_private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
  }

  assert {
    condition     = contains(keys(azurerm_private_dns_zone.default), "privatelink.vaultcore.usgovcloudapi.net")
    error_message = "The module's vault zone must exist."
  }
  assert {
    condition     = contains(keys(azurerm_private_dns_zone.default), "privatelink.blob.core.usgovcloudapi.net")
    error_message = "The module's blob zone must exist."
  }
  assert {
    condition     = length(module.tfstate_sa) == 1 && length(module.law_queries_sa) == 1
    error_message = "Both storage accounts must plan with private endpoints."
  }
  assert {
    condition     = azurerm_key_vault_secret.xadm_ssh_priv.value == null
    error_message = "The private key secret must still plan under depends_on."
  }
  assert {
    condition     = length(local.kv_private_dns_zone_ids) == 1 && local.kv_private_dns_zone_ids[0] == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/core-rg-1/providers/Microsoft.Network/privateDnsZones/mocked"
    error_message = "The module's vault zone ID must be passed to key-vault."
  }
  assert {
    condition     = local.sa_private_dns_zone_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/core-rg-1/providers/Microsoft.Network/privateDnsZones/mocked"
    error_message = "The module's blob zone ID must be passed to storage-account."
  }
}

run "private_endpoints_caller_zones" {
  command = plan

  variables {
    deploy_private_dns_zones      = false
    kv_private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
    sa_private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
    kv_private_dns_zone_ids       = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.usgovcloudapi.net"]
    sa_private_dns_zone_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.usgovcloudapi.net"
  }

  assert {
    condition     = length(azurerm_private_dns_zone.default) == 0
    error_message = "No module zones when deploy_private_dns_zones is false."
  }
  assert {
    condition     = local.kv_private_dns_zone_ids == var.kv_private_dns_zone_ids
    error_message = "Caller vault zone IDs must be passed to key-vault."
  }
  assert {
    condition     = local.sa_private_dns_zone_id == var.sa_private_dns_zone_id
    error_message = "The caller blob zone ID must be passed to storage-account."
  }
}

run "ssh_expiry_accepts_custom" {
  command = plan

  variables {
    ssh_key_secret_expiration_days = 90
  }

  assert {
    condition     = time_offset.ssh_secret_expiry.offset_days == 90
    error_message = "A custom expiry must reach time_offset."
  }
}

run "ssh_expiry_rejects_zero" {
  command = plan

  variables {
    ssh_key_secret_expiration_days = 0
  }

  expect_failures = [var.ssh_key_secret_expiration_days]
}

run "ssh_expiry_rejects_fraction" {
  command = plan

  variables {
    ssh_key_secret_expiration_days = 1.5
  }

  expect_failures = [var.ssh_key_secret_expiration_days]
}

run "tag_precedence" {
  command = plan

  variables {
    tags          = { Function = "caller", Env = "t", Owner = "test" }
    global_tags   = { Env = "g" }
    regional_tags = { Env = "r" }
  }

  assert {
    condition     = azurerm_log_analytics_workspace.core_la[0].tags["Function"] == "caller"
    error_message = "Caller tags must beat module tags."
  }
  assert {
    condition     = azurerm_log_analytics_workspace.core_la[0].tags["Env"] == "r"
    error_message = "regional_tags must beat global_tags, which beat tags."
  }
  assert {
    condition     = azurerm_private_dns_zone.default["privatelink.vaultcore.usgovcloudapi.net"].tags["Env"] == "r"
    error_message = "DNS zones must use the same tag order."
  }
  assert {
    condition     = azurerm_private_dns_zone.default["privatelink.vaultcore.usgovcloudapi.net"].tags["Plane"] == "Core"
    error_message = "DNS zones must keep the module Plane tag when the caller does not set it."
  }
}

run "location_abbreviation_rejects_uppercase" {
  command = plan

  variables {
    location_abbreviation = "USGV"
  }

  expect_failures = [var.location_abbreviation]
}

run "app_abbreviation_rejects_hyphen" {
  command = plan

  variables {
    app_abbreviation = "c-f"
  }

  expect_failures = [var.app_abbreviation]
}

run "key_size_rejects_1024" {
  command = plan

  variables {
    key_size = 1024
  }

  expect_failures = [var.key_size]
}
