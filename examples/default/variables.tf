variable "global_tags" {
  type        = map(string)
  description = "Global level tags"
  default     = {}
}

variable "regional_tags" {
  type        = map(string)
  description = "Regional level tags"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Resource level tags"
  default     = {}
}

variable "location" {
  type        = string
  description = "Azure Government region"
  default     = "usgovvirginia"
}

variable "location_abbreviation" {
  type        = string
  description = "Region code, lowercase letters and numbers"
  default     = "usgv"
}

variable "app_abbreviation" {
  type        = string
  description = "Application code, lowercase letters and numbers"
  default     = "cf"
}

variable "resource_prefix" {
  type        = string
  description = "Name prefix for resources. 13 characters or fewer keeps the default Key Vault name valid."
  default     = "ex-usgv"
}

variable "subscription_id" {
  type        = string
  description = "Subscription to deploy into"
}

variable "tenant_id" {
  type        = string
  description = "Entra ID tenant that owns the resources"
}

variable "admin_principal_ids" {
  type        = set(string)
  description = "Principals given the Key Vault admin role. Include the deploying identity."
}

variable "cidrs_for_remote_access" {
  type        = list(string)
  description = "Public IPv4 addresses or CIDRs allowed through the Key Vault firewall"
  default     = []
}

variable "kv_private_endpoint_subnet_id" {
  type        = string
  description = "Subnet for the Key Vault private endpoint"
  default     = null
}

variable "sa_private_endpoint_subnet_id" {
  type        = string
  description = "Subnet for the storage blob private endpoints"
  default     = null
}
