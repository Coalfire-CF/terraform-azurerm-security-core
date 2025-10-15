![Coalfire](coalfire_logo.png)

# terraform-azurerm-security-core

## Description

This module is the first step for deploying the [Coalfire-Azure-RAMPpak](https://github.com/Coalfire-CF/Coalfire-Azure-RAMPpak) FedRAMP Framework. It will create the core resources needed to deploy the rest of the environment.

Learn more at [Coalfire OpenSource](https://coalfire.com/opensource).

## Dependencies

- New Azure Commercial or Gov Subscription

## Resource List

- Resource group
- Vnet
- Private DNS zone if desired
- Entra ID Diagnostic logs
- Storage account to store the terraform state files
- Key Vault
- Log Analytics workspace
- Subscription diagnostics monitor

### Global-vars.tf

Update `/coalfire-azure-pak/terraform/prod/global-vars.tf` file variables:
| Name | Description | Sample |
|---|---|---|
| subscription_id | The Azure subscription ID where resources are being deployed into. This should be the subscription for the management plane | 00000000-0000-0000-0000-000000000000 |
| tenant_id | The Azure tenant ID that owns the deployed resources. Found in Entra ID properties tab in the portal | 00000000-0000-0000-0000-000000000000 |
| app_subscription_ids | The Azure subscription IDs for client application subscriptions. This should be the subscription for the application plane | ["00000000-0000-0000-0000-000000000000"] |
| app_abbreviation | two or three digit abbreviation for app resource naming | "CF" |
| cidrs_for_remote_access | List of CIDRs that will be allowed to access the resources | [""]|
| admin_principal_ids" | List of admin principal IDs that will be set as admins on resources. Found on each users properties in Entra ID | ["00000000-0000-0000-0000-000000000000"] |

## /coalfire-azure-pak/terraform/prod/us-va/security-core/core.tf

The folder you will deploy from. Most of the folder calls from the vars the only updates you need to make are enable logs or Entra ID permissions. If you're developing/testing it's probably best to turn these off because of existing permissions/log conflicts. For a new environment you should enable these.

## Deployment Steps

- Ensure the `backend "azurerm"` portion of the `tstate.tf` file is commented out for initial deployment. The state file will be created as part of this apply and we will migrate the state file to the newly created storage account.
- Ensure `remote-data.tf` file is commented out for initial deployment. This file will be used to access information in the state as the deployment progresses.
- Login to the Azure CLI: `az login`. If your subscription is in Azure Gov change the cloud first with: `az login --environment AzureUSGovernment`
- Change directories to the `/coalfire-azure-pak/terraform/prod/us-va/security-core` directory.
- Run `terraform init`.
- Run `terraform plan` to review the resources being created.
- If everything looks correct in the plan output, run `terraform apply`.

**Warning** It does take some time for the initial key vault permissions to propagate. If you get a 400 error about the Customer Managed Key for the state storage account, wait a few minutes and try again. The deployment should complete successfully.

## Migrate State

Now that the storage account exists you need to migrate the local state file to the remote state storage account.

1. Uncomment the `backend "azurerm"` portion of the `tstate.tf` file.
2. update the `resource_group_name`, `storage_account_name` and `container_name` variables to match the newly created storage account.
3. Run `terraform init` to initialize the backend. You will be prompted to migrate the state file. Select yes.
4. Run `terraform apply` to migrate the state file to the remote storage account.
5. Delete the `terraform.tfstate` and `terraform.tfstate.backup` files.
6. Uncomment the `remote-data.tf` file for the `Core` block only.
7. Commit changes and push to repo.

## Usage

```hcl
provider "azurerm" {
  features {}
}

module "core" {
  source = "github.com/Coalfire-CF/terraform-azurerm-security-core"

  subscription_id          = var.subscription_id
  resource_prefix          = local.resource_prefix
  location_abbreviation    = var.location_abbreviation
  location                 = var.location
  app_abbreviation         = var.app_abbreviation
  tenant_id                = var.tenant_id
  regional_tags            = var.regional_tags
  global_tags              = merge(var.global_tags, local.global_local_tags)
  core_rg_name             = "${local.resource_prefix}-core-rg"
  cidrs_for_remote_access  = var.cidrs_for_remote_access
  admin_principal_ids      = var.admin_principal_ids
  app_subscription_ids     = var.app_subscription_ids
  enable_sub_logs          = false
  enable_aad_logs          = false
  enable_aad_permissions   = false
  create_tfstate_storage   = true
  custom_private_dns_zones = [var.domain_name]
  azure_private_dns_zones  = [
    "privatelink.azurecr.us",
    "privatelink.database.usgovcloudapi.net",
    "privatelink.blob.core.usgovcloudapi.net",
    "privatelink.table.core.usgovcloudapi.net",
    "privatelink.queue.core.usgovcloudapi.net",
    "privatelink.file.core.usgovcloudapi.net",
    "privatelink.postgres.database.usgovcloudapi.net"
  ]
}
```

### Optional - custom resource names

You may optionally supply custom names for all resources created by this module, to support various naming convention requirements: 

```hcl
module "core" {
...
  core_rg_name                     = "arbitrary-resource-group-name"
  admin_ssh_key_name               = "arbitrary-ssh-key-name"
  key_vault_name                   = "arbitrary-key-vault-name"
  tfstate_storage_account_name     = "tfstatestorageaccountname"
  law_queries_storage_account_name = "lawquerystorageaccountname"
  log_analytics_workspace_name     = "arbitrary-log-analytics-workspace-name"
...
}
```

### Optional - Terraform state storage creation

You may optionally disable (enabled by default) the creation of the Terraform state Storage Account and container. A use case to disable it would be a multi-subscription architecture where the Terraform state files are centralized in a single Storage Account.

```hcl
module "core" {
...
  create_tfstate_storage = false
...
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ad_cmk"></a> [ad\_cmk](#module\_ad\_cmk) | git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key | v1.1.1 |
| <a name="module_ars_cmk"></a> [ars\_cmk](#module\_ars\_cmk) | git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key | v1.1.1 |
| <a name="module_avd_cmk"></a> [avd\_cmk](#module\_avd\_cmk) | git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key | v1.1.1 |
| <a name="module_cloudshell_cmk"></a> [cloudshell\_cmk](#module\_cloudshell\_cmk) | git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key | v1.1.1 |
| <a name="module_core_kv"></a> [core\_kv](#module\_core\_kv) | git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault | v1.1.1 |
| <a name="module_diag_la_queries_sa"></a> [diag\_la\_queries\_sa](#module\_diag\_la\_queries\_sa) | git::https://github.com/Coalfire-CF/terraform-azurerm-diagnostics | v1.1.0 |
| <a name="module_diag_law"></a> [diag\_law](#module\_diag\_law) | git::https://github.com/Coalfire-CF/terraform-azurerm-diagnostics | v1.1.0 |
| <a name="module_diag_sub"></a> [diag\_sub](#module\_diag\_sub) | git::https://github.com/Coalfire-CF/terraform-azurerm-diagnostics | v1.1.0 |
| <a name="module_diag_tf_state_sa"></a> [diag\_tf\_state\_sa](#module\_diag\_tf\_state\_sa) | git::https://github.com/Coalfire-CF/terraform-azurerm-diagnostics | v1.1.0 |
| <a name="module_docs_cmk"></a> [docs\_cmk](#module\_docs\_cmk) | git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key | v1.1.1 |
| <a name="module_flowlog_cmk"></a> [flowlog\_cmk](#module\_flowlog\_cmk) | git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key | v1.1.1 |
| <a name="module_install_cmk"></a> [install\_cmk](#module\_install\_cmk) | git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key | v1.1.1 |
| <a name="module_law_queries_cmk"></a> [law\_queries\_cmk](#module\_law\_queries\_cmk) | git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key | v1.1.1 |
| <a name="module_tstate_cmk"></a> [tstate\_cmk](#module\_tstate\_cmk) | git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key | v1.1.1 |
| <a name="module_vmdiag_cmk"></a> [vmdiag\_cmk](#module\_vmdiag\_cmk) | git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key | v1.1.1 |

## Resources

| Name | Type |
|------|------|
| [azuread_directory_role.app_owners](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role) | resource |
| [azuread_directory_role.groups_administrator](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role) | resource |
| [azuread_directory_role_assignment.assign_app_owners](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role_assignment) | resource |
| [azuread_directory_role_assignment.assign_groups_administrator](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role_assignment) | resource |
| [azurerm_key_vault_secret.xadm_ssh_priv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.xadm_ssh_pub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_log_analytics_linked_storage_account.law_alerts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_linked_storage_account) | resource |
| [azurerm_log_analytics_linked_storage_account.law_queries](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_linked_storage_account) | resource |
| [azurerm_log_analytics_workspace.core_la](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_aad_diagnostic_setting.aadlogs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_aad_diagnostic_setting) | resource |
| [azurerm_private_dns_zone.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_resource_group.core](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.assign_app_sub_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.assign_app_sub_user_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.assign_sub_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.assign_sub_user_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.core_kv_administrator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.law_queries_kv_crypto_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.tstate_kv_crypto_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.law_queries](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account.tf_state](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_customer_managed_key.enable_law_queries_cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_customer_managed_key) | resource |
| [azurerm_storage_account_customer_managed_key.enable_tstate_cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_customer_managed_key) | resource |
| [azurerm_storage_container.law_queries](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_container.tf_state_lock](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [tls_private_key.xadm](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [azuread_directory_roles.default](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/directory_roles) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_principal_ids"></a> [admin\_principal\_ids](#input\_admin\_principal\_ids) | admin principal ids | `set(string)` | n/a | yes |
| <a name="input_admin_ssh_key_name"></a> [admin\_ssh\_key\_name](#input\_admin\_ssh\_key\_name) | Optional custom name for admin SSH key secret in Key Vault | `string` | `"xadm-ssh-key"` | no |
| <a name="input_app_abbreviation"></a> [app\_abbreviation](#input\_app\_abbreviation) | The prefix for the blob storage account names | `string` | n/a | yes |
| <a name="input_app_subscription_ids"></a> [app\_subscription\_ids](#input\_app\_subscription\_ids) | The Azure subscription IDs for org microservices | `map(any)` | n/a | yes |
| <a name="input_azure_private_dns_zones"></a> [azure\_private\_dns\_zones](#input\_azure\_private\_dns\_zones) | List of Private DNS zones to create. | `list(string)` | <pre>[<br/>  "privatelink.azurecr.us",<br/>  "privatelink.database.usgovcloudapi.net",<br/>  "privatelink.blob.core.usgovcloudapi.net",<br/>  "privatelink.table.core.usgovcloudapi.net",<br/>  "privatelink.queue.core.usgovcloudapi.net",<br/>  "privatelink.file.core.usgovcloudapi.net",<br/>  "privatelink.documents.azure.us",<br/>  "privatelink.table.cosmos.azure.us",<br/>  "privatelink.postgres.database.usgovcloudapi.net",<br/>  "privatelink.mysql.database.usgovcloudapi.net",<br/>  "privatelink.vaultcore.usgovcloudapi.net",<br/>  "privatelink.servicebus.usgovcloudapi.net",<br/>  "privatelink.redis.cache.usgovcloudapi.net"<br/>]</pre> | no |
| <a name="input_cidrs_for_remote_access"></a> [cidrs\_for\_remote\_access](#input\_cidrs\_for\_remote\_access) | admin ciders | `list(any)` | n/a | yes |
| <a name="input_core_rg_name"></a> [core\_rg\_name](#input\_core\_rg\_name) | Resource group name for core security services | `string` | `"core-rg-1"` | no |
| <a name="input_create_ad_cmk"></a> [create\_ad\_cmk](#input\_create\_ad\_cmk) | Whether to create the AD CMK in Key Vault. | `bool` | `false` | no |
| <a name="input_create_ars_cmk"></a> [create\_ars\_cmk](#input\_create\_ars\_cmk) | Whether to create the ARS CMK in Key Vault. | `bool` | `true` | no |
| <a name="input_create_avd_cmk"></a> [create\_avd\_cmk](#input\_create\_avd\_cmk) | Whether to create the AVD CMK in Key Vault. | `bool` | `false` | no |
| <a name="input_create_cloudshell_cmk"></a> [create\_cloudshell\_cmk](#input\_create\_cloudshell\_cmk) | Whether to create the Cloud Shell CMK in Key Vault. | `bool` | `true` | no |
| <a name="input_create_docs_cmk"></a> [create\_docs\_cmk](#input\_create\_docs\_cmk) | Whether to create the Docs CMK in Key Vault. | `bool` | `true` | no |
| <a name="input_create_flowlog_cmk"></a> [create\_flowlog\_cmk](#input\_create\_flowlog\_cmk) | Whether to create the Flow Log CMK in Key Vault. | `bool` | `true` | no |
| <a name="input_create_install_cmk"></a> [create\_install\_cmk](#input\_create\_install\_cmk) | Whether to create the Install CMK in Key Vault. | `bool` | `true` | no |
| <a name="input_create_law_queries_cmk"></a> [create\_law\_queries\_cmk](#input\_create\_law\_queries\_cmk) | Whether to create the Law Queries CMK in Key Vault. | `bool` | `true` | no |
| <a name="input_create_tfstate_storage"></a> [create\_tfstate\_storage](#input\_create\_tfstate\_storage) | Enable/Disable provisioning a storage account and container for Terraform state. | `bool` | `true` | no |
| <a name="input_create_tstate_cmk"></a> [create\_tstate\_cmk](#input\_create\_tstate\_cmk) | Whether to create the TF State CMK in Key Vault. | `bool` | `true` | no |
| <a name="input_create_vmdiag_cmk"></a> [create\_vmdiag\_cmk](#input\_create\_vmdiag\_cmk) | Whether to create the VMDiag CMK in Key Vault. | `bool` | `true` | no |
| <a name="input_custom_private_dns_zones"></a> [custom\_private\_dns\_zones](#input\_custom\_private\_dns\_zones) | List of custom private DNS zones to create. | `list(string)` | `[]` | no |
| <a name="input_dr_location"></a> [dr\_location](#input\_dr\_location) | The Azure location/region for DR resources. | `string` | `"usgovtexas"` | no |
| <a name="input_enable_aad_logs"></a> [enable\_aad\_logs](#input\_enable\_aad\_logs) | Enable/Disable Entra ID logging | `bool` | `true` | no |
| <a name="input_enable_aad_permissions"></a> [enable\_aad\_permissions](#input\_enable\_aad\_permissions) | Enable/Disable provisioning basic Entra ID level permissions. | `bool` | `true` | no |
| <a name="input_enable_sub_logs"></a> [enable\_sub\_logs](#input\_enable\_sub\_logs) | Enable/Disable subscription level logging | `bool` | `true` | no |
| <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment) | Specifies whether the Key Vault is enabled for deployment. | `bool` | `true` | no |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | Specifies whether the Key Vault is enabled for disk encryption. | `bool` | `false` | no |
| <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment) | Specifies whether the Key Vault is enabled for template deployment. | `bool` | `true` | no |
| <a name="input_fedramp_high"></a> [fedramp\_high](#input\_fedramp\_high) | Whether to use FedRAMP High compliant resources (e.g., HSM-backed keys). | `bool` | `false` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Global level tags | `map(string)` | n/a | yes |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | Optional custom name for the Security Core Key Vault | `string` | `"default"` | no |
| <a name="input_kms_key_vault_network_access"></a> [kms\_key\_vault\_network\_access](#input\_kms\_key\_vault\_network\_access) | Network access configuration for the Key Vault. | `string` | `"Private"` | no |
| <a name="input_kv_subnet_ids"></a> [kv\_subnet\_ids](#input\_kv\_subnet\_ids) | A list of Subnet IDs where the Key Vault should allow communication. | `list(string)` | `[]` | no |
| <a name="input_law_queries_storage_account_name"></a> [law\_queries\_storage\_account\_name](#input\_law\_queries\_storage\_account\_name) | Optional custom name for the Terraform state Storage Account | `string` | `"default"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure location/region to create resources in | `string` | n/a | yes |
| <a name="input_location_abbreviation"></a> [location\_abbreviation](#input\_location\_abbreviation) | The  Azure location/region in 4 letter code | `string` | n/a | yes |
| <a name="input_log_analytics_data_collection_rule_id"></a> [log\_analytics\_data\_collection\_rule\_id](#input\_log\_analytics\_data\_collection\_rule\_id) | Optional Log Analytics Data Collection Rule for the workspace. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | Optional custom name for the Log Analytics Workspace | `string` | `"default"` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Specifies whether public network access is enabled for the Key Vault. | `bool` | `true` | no |
| <a name="input_regional_tags"></a> [regional\_tags](#input\_regional\_tags) | Regional level tags | `map(string)` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Name prefix used for resources | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The Azure subscription ID where resources are being deployed into | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource level tags | `map(string)` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The Azure tenant ID that owns the deployed resources | `string` | n/a | yes |
| <a name="input_tfstate_storage_account_name"></a> [tfstate\_storage\_account\_name](#input\_tfstate\_storage\_account\_name) | Optional custom name for the Terraform state Storage Account | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ad_cmk_id"></a> [ad\_cmk\_id](#output\_ad\_cmk\_id) | Active Directory CMK Key ID |
| <a name="output_ad_cmk_name"></a> [ad\_cmk\_name](#output\_ad\_cmk\_name) | Active Directory CMK Key Name |
| <a name="output_ars_cmk_id"></a> [ars\_cmk\_id](#output\_ars\_cmk\_id) | Azure Recovery Services CMK Key ID |
| <a name="output_ars_cmk_name"></a> [ars\_cmk\_name](#output\_ars\_cmk\_name) | Azure Recovery Services CMK Key Name |
| <a name="output_avd_cmk_id"></a> [avd\_cmk\_id](#output\_avd\_cmk\_id) | Azure Virtual Desktop CMK Key ID |
| <a name="output_avd_cmk_name"></a> [avd\_cmk\_name](#output\_avd\_cmk\_name) | Azure Virtual Desktop CMK Key Name |
| <a name="output_cloudshell_cmk_id"></a> [cloudshell\_cmk\_id](#output\_cloudshell\_cmk\_id) | Cloudshell CMK Key ID |
| <a name="output_cloudshell_cmk_name"></a> [cloudshell\_cmk\_name](#output\_cloudshell\_cmk\_name) | Cloudshell CMK Key Name |
| <a name="output_core_kv_id"></a> [core\_kv\_id](#output\_core\_kv\_id) | Value of the Core Key Vault ID |
| <a name="output_core_kv_name"></a> [core\_kv\_name](#output\_core\_kv\_name) | Name of the Core Key vault |
| <a name="output_core_la_id"></a> [core\_la\_id](#output\_core\_la\_id) | value of the core log analytics workspace id |
| <a name="output_core_la_primaryKey"></a> [core\_la\_primaryKey](#output\_core\_la\_primaryKey) | value of the core log analytics workspace primary key |
| <a name="output_core_la_secondaryKey"></a> [core\_la\_secondaryKey](#output\_core\_la\_secondaryKey) | value of the core log analytics workspace secondary key |
| <a name="output_core_la_workspace_id"></a> [core\_la\_workspace\_id](#output\_core\_la\_workspace\_id) | value of the core log analytics workspace id |
| <a name="output_core_la_workspace_name"></a> [core\_la\_workspace\_name](#output\_core\_la\_workspace\_name) | value of the core log analytics workspace name |
| <a name="output_core_private_dns_zone_id"></a> [core\_private\_dns\_zone\_id](#output\_core\_private\_dns\_zone\_id) | Private DNS Zone IDs |
| <a name="output_core_private_dns_zones"></a> [core\_private\_dns\_zones](#output\_core\_private\_dns\_zones) | Private DNS Zone names |
| <a name="output_core_rg_name"></a> [core\_rg\_name](#output\_core\_rg\_name) | Name of the core resource group |
| <a name="output_core_xadm_ssh_public_key"></a> [core\_xadm\_ssh\_public\_key](#output\_core\_xadm\_ssh\_public\_key) | Value of the SSH public key for xadm |
| <a name="output_docs_cmk_id"></a> [docs\_cmk\_id](#output\_docs\_cmk\_id) | Docs CMK Key ID |
| <a name="output_docs_cmk_name"></a> [docs\_cmk\_name](#output\_docs\_cmk\_name) | Docs CMK Key Name |
| <a name="output_flowlog_cmk_id"></a> [flowlog\_cmk\_id](#output\_flowlog\_cmk\_id) | Flowlogs CMK Key ID |
| <a name="output_flowlog_cmk_name"></a> [flowlog\_cmk\_name](#output\_flowlog\_cmk\_name) | Flowlogs CMK Key Name |
| <a name="output_install_cmk_id"></a> [install\_cmk\_id](#output\_install\_cmk\_id) | Installs CMK Key ID |
| <a name="output_install_cmk_name"></a> [install\_cmk\_name](#output\_install\_cmk\_name) | Installs CMK Key Name |
| <a name="output_law_queries_cmk_id"></a> [law\_queries\_cmk\_id](#output\_law\_queries\_cmk\_id) | Log Analytics Workspace Queries CMK Key ID |
| <a name="output_law_queries_cmk_name"></a> [law\_queries\_cmk\_name](#output\_law\_queries\_cmk\_name) | Log Analytics Workspace Queries CMK Key Name |
| <a name="output_tstate_cmk_id"></a> [tstate\_cmk\_id](#output\_tstate\_cmk\_id) | Terraform State CMK Key ID |
| <a name="output_tstate_cmk_name"></a> [tstate\_cmk\_name](#output\_tstate\_cmk\_name) | Terraform State CMK Key Name |
| <a name="output_vmdiag_cmk_id"></a> [vmdiag\_cmk\_id](#output\_vmdiag\_cmk\_id) | VMDiag CMK Key ID |
| <a name="output_vmdiag_cmk_name"></a> [vmdiag\_cmk\_name](#output\_vmdiag\_cmk\_name) | VMDiag CMK Key Name |
<!-- END_TF_DOCS -->

## Contributing

[Start Here](CONTRIBUTING.md)

## License

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/license/mit/)

## Contact Us

[Coalfire](https://coalfire.com/)

### Copyright

Copyright © Coalfire Systems Inc.

## Tree
```
.
|-- CONTRIBUTING.md
|-- LICENSE
|-- License.md
|-- README.md
|-- aad_permissions.tf
|-- blob_tstate.tf
|-- coalfire_logo.png
|-- core_dns.tf
|-- core_keyvault.tf
|-- core_loganalytics.tf
|-- entraid.tf
|-- locals.tf
|-- outputs.tf
|-- release-please-config.json
|-- required_version.tf
|-- resource_group.tf
|-- subscription_monitor.tf
|-- update-readme-tree.sh
|-- variables.tf
```
