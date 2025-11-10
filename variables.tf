variable "global_tags" {
  type        = map(string)
  description = "Global level tags"
}

variable "regional_tags" {
  type        = map(string)
  description = "Regional level tags"
}

variable "tags" {
  type        = map(string)
  description = "Resource level tags"
}

variable "location" {
  description = "The Azure location/region to create resources in"
  type        = string
}

variable "ip_for_remote_access" {
  description = "List of IP addresses for remote access (without CIDR notation). Storage account ip_rules will automatically reject /32 notation."
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for ip in var.ip_for_remote_access : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))
    ])
    error_message = "All IPs must be valid IPv4 addresses without CIDR notation (e.g., '203.0.113.1' not '203.0.113.1/32')."
  }
}

variable "location_abbreviation" {
  description = "The  Azure location/region in 4 letter code"
  type        = string
}

variable "app_abbreviation" {
  description = "The prefix for the blob storage account names"
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID where resources are being deployed into"
  type        = string
}

variable "app_subscription_ids" {
  description = "The Azure subscription IDs for org microservices"
  type        = map(any)
}

variable "tenant_id" {
  description = "The Azure tenant ID that owns the deployed resources"
  type        = string
}

variable "core_rg_name" {
  description = "Resource group name for core security services"
  type        = string
  default     = "core-rg-1"
}

variable "cidrs_for_remote_access" {
  description = "admin ciders"
  type        = list(any)
}

variable "admin_principal_ids" {
  description = "admin principal ids"
  type        = set(string)
}

variable "resource_prefix" {
  type        = string
  description = "Name prefix used for resources"
}

variable "enable_sub_logs" {
  type        = bool
  description = "Enable/Disable subscription level logging"
  default     = true
}

variable "enable_aad_logs" {
  type        = bool
  description = "Enable/Disable Entra ID logging"
  default     = true
}

variable "enable_aad_permissions" {
  type        = bool
  description = "Enable/Disable provisioning basic Entra ID level permissions."
  default     = true
}

variable "create_tfstate_storage" {
  type        = bool
  description = "Enable/Disable provisioning a storage account and container for Terraform state."
  default     = true
}

variable "create_law_queries_storage" {
  type        = bool
  description = "Enable/Disable provisioning a storage account and container for Log Analytics Workspace queries."
  default     = true
}

variable "deploy_private_dns_zones" {
  description = "Enable/Disable provisioning of Private DNS zones."
  type        = bool
  default     = true
}

variable "azure_private_dns_zones" {
  type        = list(string)
  description = "List of Private DNS zones to create."
  default = [
    "privatelink.azurecr.us",
    "privatelink.database.usgovcloudapi.net",
    "privatelink.blob.core.usgovcloudapi.net",
    "privatelink.table.core.usgovcloudapi.net",
    "privatelink.queue.core.usgovcloudapi.net",
    "privatelink.file.core.usgovcloudapi.net",
    "privatelink.documents.azure.us",
    "privatelink.table.cosmos.azure.us",
    "privatelink.postgres.database.usgovcloudapi.net",
    "privatelink.mysql.database.usgovcloudapi.net",
    "privatelink.vaultcore.usgovcloudapi.net",
    "privatelink.servicebus.usgovcloudapi.net",
    "privatelink.redis.cache.usgovcloudapi.net"
  ]
}

variable "custom_private_dns_zones" {
  type        = list(string)
  description = "List of custom private DNS zones to create."
  default     = []
}

variable "dr_location" {
  description = "The Azure location/region for DR resources."
  type        = string
  default     = "usgovtexas"
}

variable "log_analytics_data_collection_rule_id" {
  description = "Optional Log Analytics Data Collection Rule for the workspace."
  type        = string
  default     = null
}

variable "sa_subnet_ids" {
  type        = list(string)
  description = "List of subnet ids for access to storage accounts."
  default     = []
}

variable "sa_public_network_access_enabled" {
  type    = bool
  description = "Enable/Disable public network access for the storage account."
  default = true
}

variable "enable_customer_managed_key" {
  type = bool
  description = "Enable/Disable Customer Managed Key (CMK) for the storage account."
  default = true
}

### Optional custom name inputs ###
variable "key_vault_name" {
  description = "Optional custom name for the Security Core Key Vault"
  type        = string
  default     = "default"
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.key_vault_name))
    error_message = "Key Vault names must be between 3 and 24 characters long and can only contain letters, numbers and dashes."
  }
  validation {
    error_message = "Key Vault names must not contain two consecutive dashes"
    condition     = !can(regex("--", var.key_vault_name))
  }
  validation {
    error_message = "Key Vault names must start with a letter"
    condition     = can(regex("^[a-zA-Z]", var.key_vault_name))
  }
  validation {
    error_message = "Key Vault names must end with a letter or number"
    condition     = can(regex("[a-zA-Z0-9]$", var.key_vault_name))
  }
}
variable "tfstate_storage_account_name" {
  description = "Optional custom name for the Terraform state Storage Account"
  type        = string
  default     = "default"
  validation {
    condition     = length(var.tfstate_storage_account_name) < 25 && length(var.tfstate_storage_account_name) > 2
    error_message = "Storage account names must be between 3 and 24 characters in length"
  }
  validation {
    condition     = can(regex("^[0-9a-z]+$", var.tfstate_storage_account_name))
    error_message = "Storage account names must contain only lowercase letters and numbers"
  }
}
variable "law_queries_storage_account_name" {
  description = "Optional custom name for the Terraform state Storage Account"
  type        = string
  default     = "default"
  validation {
    condition     = length(var.law_queries_storage_account_name) < 25 && length(var.law_queries_storage_account_name) > 2
    error_message = "Storage account names must be between 3 and 24 characters in length"
  }
  validation {
    condition     = can(regex("^[0-9a-z]+$", var.law_queries_storage_account_name))
    error_message = "Storage account names must contain only lowercase letters and numbers"
  }
}
variable "log_analytics_workspace_name" {
  description = "Optional custom name for the Log Analytics Workspace"
  type        = string
  default     = "default"
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{4,63}$", var.log_analytics_workspace_name))
    error_message = "Log Analytics Workspace names must be between 4 and 63 characters long and can only contain letters, numbers and dashes."
  }
}

### Key Vault Variabeles ###

variable "enabled_for_disk_encryption" {
  description = "Specifies whether the Key Vault is enabled for disk encryption."
  type        = bool
  default     = false
}

variable "enabled_for_deployment" {
  description = "Specifies whether the Key Vault is enabled for deployment."
  type        = bool
  default     = true
}

variable "enabled_for_template_deployment" {
  description = "Specifies whether the Key Vault is enabled for template deployment."
  type        = bool
  default     = true
}

variable "kv_public_network_access_enabled" {
  description = "Specifies whether public network access is enabled for the Key Vault."
  type        = bool
  default     = true
}

variable "kms_key_vault_network_access" {
  description = "Network access configuration for the Key Vault."
  type        = string
  default     = "Private"
}

variable "kv_subnet_ids" {
  type        = list(string)
  description = "A list of Subnet IDs where the Key Vault should allow communication."
  default     = []
}

variable "create_ad_cmk" {
  description = "Whether to create the AD CMK in Key Vault."
  type        = bool
  default     = false
}

variable "create_ars_cmk" {
  description = "Whether to create the ARS CMK in Key Vault."
  type        = bool
  default     = true
}

variable "create_flowlog_cmk" {
  description = "Whether to create the Flow Log CMK in Key Vault."
  type        = bool
  default     = true  
}

variable "create_install_cmk" {
  description = "Whether to create the Install CMK in Key Vault."
  type        = bool
  default     = true
}

variable "create_tstate_cmk" {
  description = "Whether to create the TF State CMK in Key Vault."
  type        = bool
  default     = true
}

variable "create_law_queries_cmk" {
  description = "Whether to create the Law Queries CMK in Key Vault."
  type        = bool
  default     = true  
}

variable "create_cloudshell_cmk" {
  description = "Whether to create the Cloud Shell CMK in Key Vault."
  type        = bool
  default     = true    
}

variable "create_docs_cmk" {
  description = "Whether to create the Docs CMK in Key Vault."
  type        = bool
  default     = true    
}

variable "create_avd_cmk" {
  description = "Whether to create the AVD CMK in Key Vault."
  type        = bool
  default     = false    
}

variable "create_vmdisk_cmk" {
  description = "Whether to create the VM Disk CMK in Key Vault."
  type        = bool
  default     = true
}

variable "create_vmdiag_cmk" {
  description = "Whether to create the VMDiag CMK in Key Vault."
  type        = bool
  default     = true    
}

variable "create_aks_node_cmk" {
  description = "Whether to create the AKS Node CMK in Key Vault."
  type        = bool
  default     = false
}

variable "fedramp_high" {
  description = "Whether to use FedRAMP High compliant resources (e.g., KeyVault Premium, HSM-backed keys)."
  type        = bool
  default     = false
}

variable "admin_ssh_key_name" {
  description = "Optional custom name for admin SSH key secret in Key Vault"
  type        = string
  default     = "xadm-ssh-key"
}

