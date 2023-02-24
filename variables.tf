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
  description = "The Azure subscription IDs for TM microservices"
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

variable "ip_for_remote_access" {
  description = "This is the same as 'cidrs_for_remote_access' but without the /32 on each of the files. The 'ip_rules' in the storage account will not accept a '/32' address and I gave up trying to strip and convert the values over"
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

variable "private_dns_zone_name" {
  type        = string
  description = "The name of the Private DNS Zone. Must be a valid domain name."
  default     = null
}

variable "enable_sub_logs" {
  type        = bool
  description = "Enable subscription level logging"
  default     = false
}
