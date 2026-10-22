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
  description = "Public IPv4 addresses or CIDRs (up to /30) for the storage firewall. Applies only when sa_public_network_access is Enabled."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for ip in var.ip_for_remote_access : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(/([0-9]|[12][0-9]|30))?$", ip))
    ])
    error_message = "Each entry must be an IPv4 address or a CIDR up to /30 (e.g., '203.0.113.1' or '198.51.100.0/24'). Azure Storage rejects /31 and /32."
  }
}

variable "location_abbreviation" {
  description = "The Azure location/region in 4 letter code. Lowercase letters and numbers only."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.location_abbreviation))
    error_message = "location_abbreviation forms storage account and container names, which allow only lowercase letters and numbers."
  }
}

variable "app_abbreviation" {
  description = "The prefix for the blob storage account names. Lowercase letters and numbers only."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.app_abbreviation))
    error_message = "app_abbreviation forms storage account and container names, which allow only lowercase letters and numbers."
  }
}

variable "subscription_id" {
  description = "The Azure subscription ID where resources are being deployed into"
  type        = string
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
  description = "Public IPv4 addresses or CIDRs allowed through the Key Vault firewall."
  type        = list(string)
  default     = []
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

variable "create_log_analytics" {
  description = "Enable/Disable provisioning of Log Analytics Workspace."
  type        = bool
  default     = true
}

variable "diag_log_analytics_id" {
  description = "Log Analytics workspace ID that you want to send logs to (central management). Required when create_log_analytics is false."
  type        = string
  default     = null

  validation {
    condition     = var.create_log_analytics || var.diag_log_analytics_id != null
    error_message = "diag_log_analytics_id is required when create_log_analytics is false."
  }
}

variable "log_analytics_data_collection_rule_id" {
  description = "Optional Log Analytics Data Collection Rule for the workspace."
  type        = string
  default     = null
}

variable "sa_subnet_ids" {
  type        = list(string)
  description = "List of subnet ids for access to storage accounts to allow communication. Applies only when sa_public_network_access is Enabled."
  default     = []
}

variable "sa_public_network_access" {
  type        = string
  description = "Public network access for both storage accounts. Enabled exposes the endpoints, limited only by ip_for_remote_access and sa_subnet_ids."
  default     = "Disabled"

  validation {
    condition     = contains(["Disabled", "Enabled"], var.sa_public_network_access)
    error_message = "sa_public_network_access must be Disabled or Enabled."
  }
}

variable "sa_replication_type" {
  type        = string
  description = "Replication for both storage accounts. storage-account validates it. ZRS or GZRS adds zone redundancy where the region supports it (R23)."
  default     = "GRS"
}

variable "sa_blob_delete_retention_days" {
  type        = number
  description = "Blob soft delete days for both storage accounts (R22). Lower values shorten recovery."
  default     = 7
}

variable "sa_container_delete_retention_days" {
  type        = number
  description = "Container soft delete days for both storage accounts (R22). Lower values shorten recovery."
  default     = 7
}

variable "sa_point_in_time_restore_days" {
  type        = number
  description = "Point-in-time restore days for both storage accounts. Must be below sa_blob_delete_retention_days (storage-account precondition)."
  default     = 6
}

variable "sa_private_endpoint_subnet_id" {
  type        = string
  description = "Subnet for the blob private endpoint of each storage account. Null means the caller owns private access."
  default     = null
}

variable "sa_private_dns_zone_id" {
  type        = string
  description = "Blob private DNS zone ID for the storage endpoints. Null uses the module's privatelink.blob.core.usgovcloudapi.net zone when it exists."
  default     = null
}

variable "enable_customer_managed_key" {
  type        = bool
  description = "Encrypt both storage accounts with a customer-managed key that storage-account creates in the core vault. False uses platform-managed keys plus infrastructure encryption (R12)."
  default     = false
}

### Optional custom name inputs ###
variable "key_vault_name" {
  description = "Optional custom name for the Security Core Key Vault"
  type        = string
  default     = "default"
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,21}$", var.key_vault_name))
    error_message = "Key Vault names must be between 3 and 21 characters long and can only contain letters, numbers and dashes. key-vault appends -<1-99> and limits the base name to 21 characters."
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

variable "retention_in_days" {
  description = "Retention in days for log analytics"
  type        = number
  default     = 366 #1 year default
}


### Key Vault Variabeles ###

variable "enabled_for_disk_encryption" {
  description = "Specifies whether the Key Vault is enabled for disk encryption."
  type        = bool
  default     = true
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
  description = "Allow public network access to the Key Vault. True exposes the data plane to public networks, limited only by network_acls. Keep false and use kv_private_endpoint_subnet_id."
  type        = bool
  default     = false
}

variable "kms_key_vault_network_access" {
  description = "Key Vault firewall mode. Private sets the vault firewall to Deny. Public sets it to Allow, which opens the vault to any network that can reach it."
  type        = string
  default     = "Private"

  validation {
    condition     = contains(["Private", "Public"], var.kms_key_vault_network_access)
    error_message = "kms_key_vault_network_access must be Private or Public."
  }
}

variable "kv_subnet_ids" {
  type        = list(string)
  description = "A list of Subnet IDs where the Key Vault should allow communication."
  default     = []
}

variable "kv_private_endpoint_subnet_id" {
  type        = string
  description = "Subnet for the Key Vault private endpoint. Null means the caller owns private access."
  default     = null
}

variable "kv_private_dns_zone_ids" {
  type        = list(string)
  description = "Private DNS zone IDs for the Key Vault endpoint. Empty uses the module's privatelink.vaultcore.usgovcloudapi.net zone when it exists."
  default     = []
}

variable "key_vault_admin_role_definition_name" {
  type        = string
  description = "Role given to admin_principal_ids on the core Key Vault (R19)."
  default     = "Key Vault Administrator"
}

variable "key_size" {
  description = "The size of the RSA keys to create in the Key Vault. Possible values are 2048, 3072, and 4096."
  type        = number
  default     = 4096

  validation {
    condition     = contains([2048, 3072, 4096], var.key_size)
    error_message = "key_size must be 2048, 3072 or 4096."
  }
}

## SSH Key Pair
variable "ssh_algorithm" {
  description = "SSH Algorithm"
  type        = string
  default     = "RSA"
}

variable "rsa_bits" {
  description = "RSA Bit size"
  type        = number
  default     = 4096
}

variable "rotation_policy_enabled" {
  description = "Enable automatic key rotation policy"
  type        = bool
  default     = true
}

variable "rotation_expire_after" {
  description = "The duration after which the key rotation expires"
  type        = string
  default     = "P180D" #180 days
}

variable "rotation_time_before_expiry" {
  description = "The duration before expiry when the key rotation should occur"
  type        = string
  default     = "P30D" #Rotate 30 days before expiry
}

variable "create_ad_cmk" {
  description = "Whether to create the AD CMK in Key Vault. Creating a key needs vault data-plane access from the runner."
  type        = bool
  default     = false
}

variable "create_ars_cmk" {
  description = "Whether to create the ARS CMK in Key Vault. Creating a key needs vault data-plane access from the runner."
  type        = bool
  default     = false
}

variable "create_flowlog_cmk" {
  description = "Whether to create the Flow Log CMK in Key Vault. Creating a key needs vault data-plane access from the runner."
  type        = bool
  default     = false
}

variable "create_install_cmk" {
  description = "Whether to create the Install CMK in Key Vault. Creating a key needs vault data-plane access from the runner."
  type        = bool
  default     = false
}

variable "create_cloudshell_cmk" {
  description = "Whether to create the Cloud Shell CMK in Key Vault. Creating a key needs vault data-plane access from the runner."
  type        = bool
  default     = false
}

variable "create_docs_cmk" {
  description = "Whether to create the Docs CMK in Key Vault. Creating a key needs vault data-plane access from the runner."
  type        = bool
  default     = false
}

variable "create_avd_cmk" {
  description = "Whether to create the AVD CMK in Key Vault. Creating a key needs vault data-plane access from the runner."
  type        = bool
  default     = false
}

variable "create_vmdisk_cmk" {
  description = "Whether to create the VM Disk CMK in Key Vault. Creating a key needs vault data-plane access from the runner."
  type        = bool
  default     = false
}

variable "create_vmdiag_cmk" {
  description = "Whether to create the VMDiag CMK in Key Vault. Creating a key needs vault data-plane access from the runner."
  type        = bool
  default     = false
}

variable "create_aks_node_cmk" {
  description = "Whether to create the AKS Node CMK in Key Vault. Creating a key needs vault data-plane access from the runner."
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

variable "ssh_key_secret_expiration_days" {
  description = "Days until both SSH key secrets show as expired. Key Vault still returns an expired secret."
  type        = number
  default     = 365

  validation {
    condition     = var.ssh_key_secret_expiration_days >= 1 && floor(var.ssh_key_secret_expiration_days) == var.ssh_key_secret_expiration_days
    error_message = "ssh_key_secret_expiration_days must be a whole number of 1 or more."
  }
}

variable "law_internet_ingestion_enabled" {
  description = "Allow Log Analytics ingestion over the public internet. False needs an Azure Monitor Private Link Scope for agents."
  type        = bool
  default     = false
}

variable "law_internet_query_enabled" {
  description = "Allow Log Analytics queries over the public internet, including the portal from public networks."
  type        = bool
  default     = false
}

variable "law_local_authentication_enabled" {
  description = "Allow Log Analytics workspace shared-key auth. True lets key holders bypass Entra ID."
  type        = bool
  default     = false
}

variable "aad_log_categories" {
  description = "Entra ID log categories sent to Log Analytics (R20). The default is all 18 categories of the Entra diagnostic settings section. A category the tenant does not expose fails the apply; Azure Government support is unverified. Removing a category loses that audit trail."
  type        = list(string)
  default = [
    "AuditLogs",
    "SignInLogs",
    "NonInteractiveUserSignInLogs",
    "ServicePrincipalSignInLogs",
    "ManagedIdentitySignInLogs",
    "ProvisioningLogs",
    "ADFSSignInLogs",
    "RiskyUsers",
    "UserRiskEvents",
    "NetworkAccessTrafficLogs",
    "RiskyServicePrincipals",
    "ServicePrincipalRiskEvents",
    "RiskyAgents",
    "AgentRiskEvents",
    "EnrichedOffice365AuditLogs",
    "MicrosoftGraphActivityLogs",
    "RemoteNetworkHealthLogs",
    "MicrosoftServicePrincipalSignInLogs",
  ]

  validation {
    condition     = length(var.aad_log_categories) >= 1
    error_message = "aad_log_categories must list at least one category."
  }

  validation {
    condition     = !contains(var.aad_log_categories, "CustomSecurityAttributeAuditLogs")
    error_message = "CustomSecurityAttributeAuditLogs is configured in the Custom security attributes section of diagnostic settings; the caller owns that setting."
  }
}
