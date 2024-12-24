terraform {
  required_version = "~>1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      #version = "~> 3.45.0"
      version = "~> 4.0" # 4.0 isn't compatible with pak currently
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0" # 3.0 appears bugged: https://github.com/hashicorp/terraform-provider-azuread/issues/1526
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}