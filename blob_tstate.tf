# Terraform state storage. storage-account v3 owns the container, the diagnostic setting and the optional CMK key.
module "tfstate_sa" {
  source = "git::https://github.com/Coalfire-CF/terraform-azurerm-storage-account?ref=v3.0.0"

  count = var.create_tfstate_storage ? 1 : 0

  name                       = local.tfstate_storage_account_name
  resource_group_name        = azurerm_resource_group.core.name
  location                   = var.location
  account_kind               = "StorageV2"
  replication_type           = var.sa_replication_type
  public_network_access      = var.sa_public_network_access
  ip_rules                   = var.ip_for_remote_access
  virtual_network_subnet_ids = var.sa_subnet_ids
  diag_log_analytics_id      = local.law_id

  endpoint_subnet_id  = var.sa_private_endpoint_subnet_id
  private_dns_zone_id = local.sa_private_dns_zone_id

  storage_containers = [local.tfstate_container_name]

  blob_delete_retention_days      = var.sa_blob_delete_retention_days
  container_delete_retention_days = var.sa_container_delete_retention_days
  point_in_time_restore_days      = var.sa_point_in_time_restore_days

  enable_customer_managed_key     = var.enable_customer_managed_key
  cmk_key_vault_id                = module.core_kv.key_vault_id
  cmk_key_type                    = var.fedramp_high ? "RSA-HSM" : "RSA"
  cmk_key_size                    = var.key_size
  cmk_rotation_policy_enabled     = var.rotation_policy_enabled
  cmk_rotation_expire_after       = var.rotation_expire_after
  cmk_rotation_time_before_expiry = var.rotation_time_before_expiry

  tags = local.storage_tags

  # The CMK key write needs the deployer's vault role and, on the private path, the vault private endpoint.
  depends_on = [module.core_kv, azurerm_role_assignment.core_kv_administrator]
}
