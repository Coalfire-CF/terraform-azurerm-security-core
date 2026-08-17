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
1. update the `resource_group_name`, `storage_account_name` and `container_name` variables to match the newly created storage account.
1. Run `terraform init` to initialize the backend. You will be prompted to migrate the state file. Select yes.
1. Run `terraform apply` to migrate the state file to the remote storage account.
1. Delete the `terraform.tfstate` and `terraform.tfstate.backup` files.
1. Uncomment the `remote-data.tf` file for the `Core` block only.
1. Commit changes and push to repo.

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

