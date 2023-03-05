# Coalfire Azure Core Security Components

## Description

This module is the first step for deploying the Coalfire Azure FedRAMP Framework. It will create the core resources needed to deploy the rest of the environment.

## Resource List

- Vnet
- Private DNS zone if desired
- AAD Diagnostic logs
- Storage account to store the terraform state files
- Key Vault
- Log Analytics workspace
- Resource group
- Subscription diagnostics monitor

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| location | The Azure location/region to create resources in | string | N/A | yes |
| resource_prefix | Name prefix used for resources | string | N/A | yes |
| location_abbreviation | The  Azure location/region in 4 letter code | string | N/A | yes |
| app_abbreviation | The prefix for the blob storage account names | string | N/A | yes |
| subscription_id | The Azure subscription ID where resources are being deployed into | string | N/A | yes |
| tenant_id | The Azure tenant ID that owns the deployed resources | string | N/A | yes |
| sub_diag_logs | Types of logs to gather for subscription diagnostics | list(any) | N/A | yes |
| cidrs_for_remote_access | admin ciders | list(any) | N/A | yes |
| ip_for_remote_access | This is the same as 'cidrs_for_remote_access' but without the /32 on each of the files. The 'ip_rules' in the storage account will not accept a '/32' address and I gave up trying to strip and convert the values over | list(any) | N/A | yes |
| admin_principal_ids | admin principal ids | set(string) | N/A | yes |
| tags | The tags to associate with your network and subnets | map(string) | N/A | yes |
| regional_tags | Regional level tags | map(string) | N/A | yes |
| global_tags | Global level tags | map(string) | N/A | yes |
| core_rg_name | Resource group name for core security services | string | core-rg-1 | no |
| private_dns_zone_name | The name of the Private DNS Zone. Must be a valid domain name. If passed, it will create a vnet link with the private DNS zone | string | null | no |
| app_subscription_ids | The Azure subscription IDs for TM microservices | list(string) | [] | no |
| enable_diag_logs | Enable diagnostic logs for AAD | bool | false | no |
| enable_aad_logs | Enable diagnostic logs for AAD | bool | false | no |
| enable_sub_diag | Enable subscription diagnostics | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| core_rg_name | The resource group name |
| core_vnet_id | The ID of the newly created VNet |
| core_vnet_name | The Name of the newly created VNet  |
| core_vnet_subnet_ids | Map of subnets with their ids |
| core_la_id | The ID of the log analytics workspace |
| core_la_primaryKey | The primary key of the log analytics workspace |
| core_la_secondaryKey | The secondary key of the log analytics workspace |
| core_la_workspace_id | The ID of the log analytics workspace |
| core_la_workspace_name | The name of the log analytics workspace |
| core_kv_id | The ID of the Key Vault |
| ad-cmk_id | The id of the customer managed key for AD |
| ars-cmk_id | The id of the customer managed key for ars |
| flowlog-cmk_id | The id of the customer managed key for flow logs |
| install-cmk_id | The id of the customer managed key for installs |
| tstate-cmk_id | The id of the customer managed key for terraform state |
| cloudshell-cmk_id | The id of the customer managed key for cloudshell |
| docs-cmk_id | The id of the customer managed key for docs |
| avd-cmk_id | The id of the customer managed key for avd |
| core_private_dns_zone_name | The name of the Private DNS Zone |
| core_private_dns_zone_id | The ID of the Private DNS Zone |
| core_xadm_ssh_public_key | The SSH public key for the xadm account |

## Usage

```hcl
module "core" {
  source = "github.com:Coalfire-CF/ACE-Azure-SecurityCore?ref=v1.0.0"

  subscription_id         = var.subscription_id
  resource_prefix         = local.resource_prefix
  location_abbreviation   = var.location_abbreviation
  location                = var.location
  app_abbreviation        = var.app_abbreviation
  tenant_id               = var.tenant_id
  regional_tags           = var.regional_tags
  global_tags             = var.global_tags
  core_rg_name            = "${local.resource_prefix}-core-rg"
  cidrs_for_remote_access = var.cidrs_for_remote_access
  ip_for_remote_access    = var.ip_for_remote_access
  admin_principal_ids     = var.admin_principal_ids
  enable_diag_logs        = true
  enable_aad_logs         = true
  #diag_law_id             = data.terraform_remote_state.core.outputs.core_la_id
  sub_diag_logs = [
    "Administrative",
    "Security",
    "ServiceHealth",
    "Alert",
    "Recommendation",
    "Policy",
    "Autoscale",
    "ResourceHealth"
  ]
}
```
