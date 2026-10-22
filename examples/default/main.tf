terraform {
  required_version = ">= 1.16.6, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.10"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.14"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  environment                     = "usgovernment"
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
  resource_providers_to_register = [
    "Microsoft.Insights",
    "Microsoft.KeyVault",
    "Microsoft.Network",
    "Microsoft.OperationalInsights",
    "Microsoft.Storage",
  ]
  storage_use_azuread = true
}

module "core" {
  source = "../.."

  global_tags           = var.global_tags
  regional_tags         = var.regional_tags
  tags                  = var.tags
  location              = var.location
  location_abbreviation = var.location_abbreviation
  app_abbreviation      = var.app_abbreviation
  subscription_id       = var.subscription_id
  tenant_id             = var.tenant_id
  admin_principal_ids   = var.admin_principal_ids
  resource_prefix       = var.resource_prefix

  cidrs_for_remote_access       = var.cidrs_for_remote_access
  kv_private_endpoint_subnet_id = var.kv_private_endpoint_subnet_id
  sa_private_endpoint_subnet_id = var.sa_private_endpoint_subnet_id
}
