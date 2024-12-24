variable "global_tags" {
  type        = map(string)
  description = "Global level tags"
}

variable "regional_tags" {
  type        = map(string)
  description = "Regional level tags"
}

variable "location" {
  description = "The Azure location/region to create resources in"
  type        = string
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

variable "azure_private_dns_zones" {
  type        = list(string)
  description = "List of Private DNS zones to create."
  default = [
    "privatelink.azurecr.us",
    "privatelink.azuredatabricks.net",
    "privatelink.database.usgovcloudapi.net",
    "privatelink.datafactory.azure.net",
    "privatelink.blob.core.usgovcloudapi.net",
    "privatelink.table.core.usgovcloudapi.net",
    "privatelink.queue.core.usgovcloudapi.net",
    "privatelink.file.core.usgovcloudapi.net",
    "privatelink.documents.azure.us",
    "privatelink.mongo.cosmos.azure.us",
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