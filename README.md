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
  enable_tfstate_storage   = true
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

  # uncomment and rerun terraform apply after the networks are created if you're using FWs
  #fw_virtual_network_subnet_ids = data.terraform_remote_state.usgv_mgmt_vnet.outputs.usgv_mgmt_vnet_subnet_ids["${local.resource_prefix}-bastion-sn-1"] #Uncomment and rerun terraform apply after the mgmt-network is created
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
  enable_tfstate_storage = false
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
| <a name="module_core_kv"></a> [core\_kv](#module\_core\_kv) | git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault | v1.0.2 |
| <a name="module_diag_la_queries_sa"></a> [diag\_la\_queries\_sa](#module\_diag\_la\_queries\_sa) | git::https://github.com/Coalfire-CF/terraform-azurerm-diagnostics | v1.0.0 |
| <a name="module_diag_law"></a> [diag\_law](#module\_diag\_law) | git::https://github.com/Coalfire-CF/terraform-azurerm-diagnostics | v1.0.0 |
| <a name="module_diag_sub"></a> [diag\_sub](#module\_diag\_sub) | git::https://github.com/Coalfire-CF/terraform-azurerm-diagnostics | v1.0.0 |
| <a name="module_diag_tf_state_sa"></a> [diag\_tf\_state\_sa](#module\_diag\_tf\_state\_sa) | git::https://github.com/Coalfire-CF/terraform-azurerm-diagnostics | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_directory_role.app_owners](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role) | resource |
| [azuread_directory_role.groups_administrator](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role) | resource |
| [azuread_directory_role_assignment.assign_app_owners](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role_assignment) | resource |
| [azuread_directory_role_assignment.assign_groups_administrator](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role_assignment) | resource |
| [azurerm_key_vault_key.ad-cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_key_vault_key.ars-cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_key_vault_key.avd-cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_key_vault_key.cloudshell-cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_key_vault_key.docs-cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_key_vault_key.flowlog-cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_key_vault_key.install-cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_key_vault_key.law_queries-cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_key_vault_key.tstate-cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_key_vault_secret.xadm_ssh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_log_analytics_linked_storage_account.law_alerts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_linked_storage_account) | resource |
| [azurerm_log_analytics_linked_storage_account.law_queries](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_linked_storage_account) | resource |
| [azurerm_log_analytics_workspace.core-la](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
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
| [azurerm_storage_management_policy.lifecycle_mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |
| [tls_private_key.xadm](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_principal_ids"></a> [admin\_principal\_ids](#input\_admin\_principal\_ids) | admin principal ids | `set(string)` | n/a | yes |
| <a name="input_admin_ssh_key_name"></a> [admin\_ssh\_key\_name](#input\_admin\_ssh\_key\_name) | Optional custom name for admin SSH key secret in Key Vault | `string` | `"xadm-ssh-private-key"` | no |
| <a name="input_app_abbreviation"></a> [app\_abbreviation](#input\_app\_abbreviation) | The prefix for the blob storage account names | `string` | n/a | yes |
| <a name="input_app_subscription_ids"></a> [app\_subscription\_ids](#input\_app\_subscription\_ids) | The Azure subscription IDs for org microservices | `map(any)` | n/a | yes |
| <a name="input_azure_private_dns_zones"></a> [azure\_private\_dns\_zones](#input\_azure\_private\_dns\_zones) | List of Private DNS zones to create. | `list(string)` | <pre>[<br/>  "privatelink.azurecr.us",<br/>  "privatelink.azuredatabricks.net",<br/>  "privatelink.database.usgovcloudapi.net",<br/>  "privatelink.datafactory.azure.net",<br/>  "privatelink.blob.core.usgovcloudapi.net",<br/>  "privatelink.table.core.usgovcloudapi.net",<br/>  "privatelink.queue.core.usgovcloudapi.net",<br/>  "privatelink.file.core.usgovcloudapi.net",<br/>  "privatelink.documents.azure.us",<br/>  "privatelink.mongo.cosmos.azure.us",<br/>  "privatelink.table.cosmos.azure.us",<br/>  "privatelink.postgres.database.usgovcloudapi.net",<br/>  "privatelink.mysql.database.usgovcloudapi.net",<br/>  "privatelink.vaultcore.usgovcloudapi.net",<br/>  "privatelink.servicebus.usgovcloudapi.net",<br/>  "privatelink.redis.cache.usgovcloudapi.net"<br/>]</pre> | no |
| <a name="input_cidrs_for_remote_access"></a> [cidrs\_for\_remote\_access](#input\_cidrs\_for\_remote\_access) | admin ciders | `list(any)` | n/a | yes |
| <a name="input_core_rg_name"></a> [core\_rg\_name](#input\_core\_rg\_name) | Resource group name for core security services | `string` | `"core-rg-1"` | no |
| <a name="input_custom_private_dns_zones"></a> [custom\_private\_dns\_zones](#input\_custom\_private\_dns\_zones) | List of custom private DNS zones to create. | `list(string)` | `[]` | no |
| <a name="input_dr_location"></a> [dr\_location](#input\_dr\_location) | The Azure location/region for DR resources. | `string` | `"usgovtexas"` | no |
| <a name="input_enable_aad_logs"></a> [enable\_aad\_logs](#input\_enable\_aad\_logs) | Enable/Disable Entra ID logging | `bool` | `true` | no |
| <a name="input_enable_aad_permissions"></a> [enable\_aad\_permissions](#input\_enable\_aad\_permissions) | Enable/Disable provisioning basic Entra ID level permissions. | `bool` | `true` | no |
| <a name="input_enable_sub_logs"></a> [enable\_sub\_logs](#input\_enable\_sub\_logs) | Enable/Disable subscription level logging | `bool` | `true` | no |
| <a name="input_enable_tfstate_storage"></a> [enable\_tfstate\_storage](#input\_enable\_tfstate\_storage) | Enable/Disable provisioning a storage account and container for Terraform state. | `bool` | `true` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Global level tags | `map(string)` | n/a | yes |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | Optional custom name for the Security Core Key Vault | `string` | `"default"` | no |
| <a name="input_law_queries_storage_account_name"></a> [law\_queries\_storage\_account\_name](#input\_law\_queries\_storage\_account\_name) | Optional custom name for the Terraform state Storage Account | `string` | `"default"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure location/region to create resources in | `string` | n/a | yes |
| <a name="input_location_abbreviation"></a> [location\_abbreviation](#input\_location\_abbreviation) | The  Azure location/region in 4 letter code | `string` | n/a | yes |
| <a name="input_log_analytics_data_collection_rule_id"></a> [log\_analytics\_data\_collection\_rule\_id](#input\_log\_analytics\_data\_collection\_rule\_id) | Optional Log Analytics Data Collection Rule for the workspace. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | Optional custom name for the Log Analytics Workspace | `string` | `"default"` | no |
| <a name="input_regional_tags"></a> [regional\_tags](#input\_regional\_tags) | Regional level tags | `map(string)` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Name prefix used for resources | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The Azure subscription ID where resources are being deployed into | `string` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The Azure tenant ID that owns the deployed resources | `string` | n/a | yes |
| <a name="input_tfstate_storage_account_name"></a> [tfstate\_storage\_account\_name](#input\_tfstate\_storage\_account\_name) | Optional custom name for the Terraform state Storage Account | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ad-cmk_id"></a> [ad-cmk\_id](#output\_ad-cmk\_id) | AD SA CMK ID |
| <a name="output_ars-cmk_id"></a> [ars-cmk\_id](#output\_ars-cmk\_id) | Azure Recovery Services SA CMK ID |
| <a name="output_avd-cmk_id"></a> [avd-cmk\_id](#output\_avd-cmk\_id) | Azure Virtual Desktop CMK ID |
| <a name="output_cloudshell-cmk_id"></a> [cloudshell-cmk\_id](#output\_cloudshell-cmk\_id) | Cloudshell SA CMK ID |
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
| <a name="output_docs-cmk_id"></a> [docs-cmk\_id](#output\_docs-cmk\_id) | Docs SA CMK ID |
| <a name="output_flowlog-cmk_id"></a> [flowlog-cmk\_id](#output\_flowlog-cmk\_id) | Flowlogs SA CMK ID |
| <a name="output_install-cmk_id"></a> [install-cmk\_id](#output\_install-cmk\_id) | Installs SA CMK ID |
| <a name="output_law_queries-cmk_id"></a> [law\_queries-cmk\_id](#output\_law\_queries-cmk\_id) | Log Analytics Workspace Queries SA CMK ID |
| <a name="output_tstate-cmk_id"></a> [tstate-cmk\_id](#output\_tstate-cmk\_id) | Terraform State SA CMK ID |
<!-- END_TF_DOCS -->

## Contributing

[Start Here](CONTRIBUTING.md)

## License

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/license/mit/)

## Contact Us

[Coalfire](https://coalfire.com/)

### Copyright

Copyright © Coalfire Systems Inc.
