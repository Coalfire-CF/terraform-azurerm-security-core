![Coalfire](coalfire_logo.png)

# terraform-azurerm-security-core

## Description

A reusable module that creates the core security resources for an Azure Government environment:

- The core resource group.
- A Log Analytics workspace (optional; you can send logs to an existing one).
- The core Key Vault, with optional customer-managed keys (CMK) for downstream services.
- A storage account and container for Terraform state (optional).
- A storage account for Log Analytics query and alert storage (only when this module creates the workspace).
- Private DNS zones. They are not linked to any virtual network; the caller links them.
- Entra ID diagnostic logs and subscription Activity Log diagnostics.

Learn more at [Coalfire OpenSource](https://coalfire.com/opensource).

## Prerequisites

- The deploying identity must be in `admin_principal_ids`. The vault uses Azure RBAC, so the deployer needs the Key Vault role to write keys and secrets.
- Entra ID diagnostics need the Security Administrator role in the tenant.
- The vault and both storage accounts are private by default. Writing keys and secrets needs one of two setups:
  - A private endpoint (`kv_private_endpoint_subnet_id`, and `sa_private_endpoint_subnet_id` for storage) plus a runner that can reach the subnet and resolve `privatelink.vaultcore.usgovcloudapi.net` and `privatelink.blob.core.usgovcloudapi.net`. The caller links the zones to the runner's virtual network. Terraform waits for the whole key-vault module, including its private endpoint, before it writes keys and secrets. It cannot create the virtual network link.
  - `kv_public_network_access_enabled = true` with `cidrs_for_remote_access`.
- Both storage accounts disable Shared Key authorization. A backend that uses the state account must set `use_azuread_auth = true`. Writers need `Storage Blob Data Contributor`; readers need `Storage Blob Data Reader`.
- Log Analytics internet ingestion, internet query and local authentication are off by default. Agents need an Azure Monitor Private Link Scope. Portal queries from public networks need `law_internet_query_enabled = true`.
- When `key_vault_name` is left at `default`, the vault name is `<resource_prefix>-core-kv`. Keep `resource_prefix` at 13 characters or fewer, or key-vault rejects the name.

## Key Vault

key-vault appends `-<1-99>` to the vault name, as in v2. Read the real name from the `core_kv_name` output. A custom `key_vault_name` is limited to 21 characters for this reason.

The vault firewall keeps `bypass = AzureServices`. Storage CMK and the `enabled_for_*` flags need trusted Azure services while the firewall denies. key-vault v3 defaults the bypass to `None`.

The private SSH key is written to the vault through the write-only `value_wo` argument, so it is not stored in the secret's state. It is still in the `tls_private_key` state. Both SSH secrets get an expiry date (`ssh_key_secret_expiration_days`, default 365). Key Vault still returns an expired secret.

## Customer-managed keys

CMK is off by default (R12). Storage uses platform-managed keys plus infrastructure encryption. There are two opt-ins:

- `enable_customer_managed_key = true` makes storage-account create a key in the core vault for each storage account and grant the storage identity access to it.
- Each `create_*_cmk` input creates one key in the core vault for a downstream service.

Creating a key needs vault data-plane access from the runner.

## Entra ID log categories

Source: [Entra diagnostic settings log options](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/concept-diagnostic-settings-logs-options), updated 2026-05-12.

The default (`aad_log_categories`) sends all 18 categories of the Entra diagnostic settings section (R20). v2 sent 13. Added in v3:

- `RiskyAgents` and `AgentRiskEvents` (ID Protection for agents).
- `NetworkAccessTrafficLogs`, `EnrichedOffice365AuditLogs` and `RemoteNetworkHealthLogs` (Global Secure Access). They add no data unless Global Secure Access is in use.

`MicrosoftServicePrincipalSignInLogs` is a preview category. Microsoft says it is high volume and not needed by most customers, so check the ingestion cost. It is kept because R20 asks for all categories.

`CustomSecurityAttributeAuditLogs` is not part of this setting. Microsoft configures it in the separate "Custom security attributes" section of diagnostic settings, with the Attribute Log Administrator role. The caller owns that setting, and validation rejects the category here.

Azure Government support is not verified for any category. A category the tenant does not expose fails the apply. Remove it with `aad_log_categories`.

## Recovery and redundancy

Storage soft delete and point-in-time restore are on. Set retention with `sa_blob_delete_retention_days`, `sa_container_delete_retention_days` and `sa_point_in_time_restore_days`. Replication defaults to GRS (`sa_replication_type`); ZRS or GZRS adds zone redundancy where the region supports it. azurerm 5.10.0 does not expose Log Analytics zone redundancy.

## Breaking changes from v2

- Requires Terraform `>= 1.16.6, < 2.0` and azurerm `~> 5.10`. The `azuread` provider is removed. `hashicorp/time ~> 0.14` is added.
- Inputs removed: `app_subscription_ids`, `enable_aad_permissions`, `sa_public_network_access_enabled`, `create_tstate_cmk`, `create_law_queries_cmk`. The subscription `Contributor` and `User Access Administrator` assignments and Entra directory role activation are gone; the caller owns them.
- `sa_public_network_access_enabled` (bool) is replaced by `sa_public_network_access` (string, default `Disabled`).
- `cidrs_for_remote_access` is now `list(string)` with default `[]`. `key_size` is now a number (2048, 3072 or 4096).
- Defaults changed from true to false: `kv_public_network_access_enabled`, `enable_customer_managed_key`, `create_ars_cmk`, `create_flowlog_cmk`, `create_install_cmk`, `create_cloudshell_cmk`, `create_docs_cmk`, `create_vmdisk_cmk`, `create_vmdiag_cmk`.
- New validation: `key_vault_name` 3 to 21 characters; `kms_key_vault_network_access` is `Private` or `Public`; `diag_log_analytics_id` is required when `create_log_analytics = false`; `ip_for_remote_access` accepts addresses and CIDRs up to /30; `location_abbreviation` and `app_abbreviation` are lowercase letters and numbers.
- Storage diagnostics, storage CMK keys and the state and query containers are created inside storage-account v3. LAW query storage is created only when this module creates the workspace.
- Outputs removed: `core_la_primaryKey`, `core_la_secondaryKey`, `tstate_cmk_id`, `tstate_cmk_resource_id`, `tstate_cmk_name`, `law_queries_cmk_id`, `law_queries_cmk_resource_id`, `law_queries_cmk_name`. Output added: `tfstate_container_name`.
- Tag precedence is now one order everywhere: module `Function`/`Plane`, then `tags`, then `global_tags`, then `regional_tags` (later wins). DNS zones, the workspace, storage accounts, the resource group, vault keys and SSH secrets all follow it.
- The Entra diagnostic setting sends 18 categories instead of 13.

## Usage

```hcl
provider "azurerm" {
  features {}
  environment                     = "usgovernment"
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
  storage_use_azuread             = true
}

module "core" {
  source = "git::https://github.com/Coalfire-CF/terraform-azurerm-security-core?ref=v3.0.0"

  subscription_id       = var.subscription_id
  tenant_id             = var.tenant_id
  resource_prefix       = "ex-usgv"
  location              = "usgovvirginia"
  location_abbreviation = "usgv"
  app_abbreviation      = "cf"
  admin_principal_ids   = var.admin_principal_ids
  global_tags           = var.global_tags
  regional_tags         = var.regional_tags
  tags                  = var.tags

  kv_private_endpoint_subnet_id = var.pe_subnet_id
  sa_private_endpoint_subnet_id = var.pe_subnet_id
}
```

See `examples/default` for a complete root. With `resource_provider_registrations = "none"`, confirm on the first apply that the subscription has the providers it needs registered. Registration of `Microsoft.AADIAM` for the Entra diagnostic setting is not verified.

### Optional - custom resource names

You may optionally supply custom names for all resources created by this module, to support various naming convention requirements:

```hcl
module "core" {
...
  core_rg_name                     = "arbitrary-resource-group-name"
  admin_ssh_key_name               = "arbitrary-ssh-key-name"
  key_vault_name                   = "arbitrary-kv-name"
  tfstate_storage_account_name     = "tfstatestorageaccountname"
  law_queries_storage_account_name = "lawquerystorageaccountname"
  log_analytics_workspace_name     = "arbitrary-log-analytics-workspace-name"
...
}
```

A custom `key_vault_name` must be 21 characters or fewer.

### Optional - Terraform state storage creation

You may optionally disable (enabled by default) the creation of the Terraform state Storage Account and container. A use case to disable it would be a multi-subscription architecture where the Terraform state files are centralized in a single Storage Account.

```hcl
module "core" {
...
  create_tfstate_storage = false
...
}
```

**Warning** It takes some time for the initial Key Vault role assignments to propagate. If you get a 403 or 400 error writing a key or secret, wait a few minutes and run the apply again.
