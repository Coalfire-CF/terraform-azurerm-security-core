# Core Key Vault
module "core_kv" {
  source                          = "git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault?ref=v1.1.1"
  
  kv_name                         = local.key_vault_name
  sku_name                        = var.fedramp_high ? "premium" : "standard"
  resource_group_name             = var.core_rg_name
  location                        = var.location
  tenant_id                       = var.tenant_id
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
  public_network_access_enabled   = var.public_network_access_enabled
  diag_log_analytics_id           = azurerm_log_analytics_workspace.core_la.id

  regional_tags                   = var.regional_tags
  global_tags                     = var.global_tags
  tags                            = var.tags

  network_acls = {
    bypass                     = "AzureServices"
    default_action             = var.kms_key_vault_network_access == "Private" ? "Deny" : "Allow"
    virtual_network_subnet_ids = var.kms_key_vault_network_access == "Private" ?  var.kv_subnet_ids : []
    ip_rules                   = var.cidrs_for_remote_access
  }

  depends_on = [azurerm_resource_group.core]
}

### Core KV Role Assignments ###
resource "azurerm_role_assignment" "core_kv_administrator" {
  for_each             = var.admin_principal_ids
  scope                = module.core_kv.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.key
}


##### FedRAMP Moderate Key Vault Keys for CMK ######

### AD CMK with custom rotation policy ###
module "ad_cmk" {
  source = "git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key?ref=v1.1.1"

  count = var.create_ad_cmk ? 1 : 0

  name         = "ad-cmk"
  key_type     = var.fedramp_high ? "RSA-HSM" : "RSA"
  key_vault_id = module.core_kv.key_vault_id
  key_size     = 4096

  # Custom rotation policy
  rotation_policy_enabled    = true
  rotation_expire_after      = "P180D"  # 180 days
  rotation_time_before_expiry = "P30D"   # Rotate 30 days before expiry

  tags = var.tags

  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

### Azure Recovery Service (ARS) CMK with custom rotation policy ###
module "ars_cmk" {
  source = "git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key?ref=v1.1.1"

  count = var.create_ars_cmk ? 1 : 0

  name         = "ars-cmk"
  key_type     = var.fedramp_high ? "RSA-HSM" : "RSA"
  key_vault_id = module.core_kv.key_vault_id
  key_size     = 4096

  # Custom rotation policy
  rotation_policy_enabled    = true
  rotation_expire_after      = "P180D"  # 180 days
  rotation_time_before_expiry = "P30D"   # Rotate 30 days before expiry

  tags = var.tags
  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

### Flow Log CMK with custom rotation policy ###
module "flowlog_cmk" {
  source = "git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key?ref=v1.1.1"

  count = var.create_flowlog_cmk ? 1 : 0

  name         = "flowlog-cmk"
  key_type     = var.fedramp_high ? "RSA-HSM" : "RSA"
  key_vault_id = module.core_kv.key_vault_id
  key_size     = 4096

  # Custom rotation policy
  rotation_policy_enabled    = true
  rotation_expire_after      = "P180D"  # 180 days
  rotation_time_before_expiry = "P30D"   # Rotate 30 days before expiry

  tags = var.tags
  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

### Install CMK with custom rotation policy ###
module "install_cmk" {
  source = "git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key?ref=v1.1.1"

  count = var.create_install_cmk ? 1 : 0

  name         = "install-cmk"
  key_type     = var.fedramp_high ? "RSA-HSM" : "RSA"
  key_vault_id = module.core_kv.key_vault_id
  key_size     = 4096

  # Custom rotation policy
  rotation_policy_enabled    = true
  rotation_expire_after      = "P180D"  # 180 days
  rotation_time_before_expiry = "P30D"   # Rotate 30 days before expiry

  tags = var.tags
  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

### TF State CMK with custom rotation policy ###
module "tstate_cmk" {
  source = "git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key?ref=v1.1.1"

  count  = var.create_tfstate_storage ? 1 : 0

  name         = "tstate-cmk"
  key_type     = var.fedramp_high ? "RSA-HSM" : "RSA"
  key_vault_id = module.core_kv.key_vault_id
  key_size     = 4096

  # Custom rotation policy
  rotation_policy_enabled    = true
  rotation_expire_after      = "P180D"  # 180 days
  rotation_time_before_expiry = "P30D"   # Rotate 30 days before expiry

  tags = var.tags
  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

### Law Queries CMK with custom rotation policy ###
module "law_queries_cmk" {
  source = "git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key?ref=v1.1.1"

  count = var.create_law_queries_cmk ? 1 : 0

  name         = "law-queries-cmk"
  key_type     = var.fedramp_high ? "RSA-HSM" : "RSA"
  key_vault_id = module.core_kv.key_vault_id
  key_size     = 4096

  # Custom rotation policy
  rotation_policy_enabled    = true
  rotation_expire_after      = "P180D"  # 180 days
  rotation_time_before_expiry = "P30D"   # Rotate 30 days before expiry

  tags = var.tags
  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

### Cloud Shell CMK with custom rotation policy ###
module "cloudshell_cmk" {
  source = "git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key?ref=v1.1.1"

  count = var.create_cloudshell_cmk ? 1 : 0

  name         = "cloudshell-cmk"
  key_type     = var.fedramp_high ? "RSA-HSM" : "RSA"
  key_vault_id = module.core_kv.key_vault_id
  key_size     = 4096

  # Custom rotation policy
  rotation_policy_enabled    = true
  rotation_expire_after      = "P180D"  # 180 days
  rotation_time_before_expiry = "P30D"   # Rotate 30 days before expiry

  tags = var.tags
  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

### Documentation CMK with custom rotation policy ###
module "docs_cmk" {
  source = "git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key?ref=v1.1.1"

  count = var.create_docs_cmk ? 1 : 0

  name         = "docs-cmk"
  key_type     = var.fedramp_high ? "RSA-HSM" : "RSA"
  key_vault_id = module.core_kv.key_vault_id
  key_size     = 4096

  # Custom rotation policy
  rotation_policy_enabled    = true
  rotation_expire_after      = "P180D"  # 180 days
  rotation_time_before_expiry = "P30D"   # Rotate 30 days before expiry

  tags = var.tags
  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

### Azure Virtual Desktop (AVD) CMK with custom rotation policy ###
module "avd_cmk" {
  source = "git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key?ref=v1.1.1"

  count = var.create_avd_cmk ? 1 : 0

  name         = "avd-cmk"
  key_type     = var.fedramp_high ? "RSA-HSM" : "RSA"
  key_vault_id = module.core_kv.key_vault_id
  key_size     = 4096

  # Custom rotation policy
  rotation_policy_enabled    = true
  rotation_expire_after      = "P180D"  # 180 days
  rotation_time_before_expiry = "P30D"   # Rotate 30 days before expiry

  tags = var.tags
  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

### VM Diagnostics CMK with custom rotation policy ###
module "vmdiag_cmk" {
  source = "git::https://github.com/Coalfire-CF/terraform-azurerm-key-vault//modules/kv_key?ref=v1.1.1"

  count = var.create_vmdiag_cmk ? 1 : 0

  name         = "vmdiag-cmk"
  key_type     = var.fedramp_high ? "RSA-HSM" : "RSA"
  key_vault_id = module.core_kv.key_vault_id
  key_size     = 4096

  # Custom rotation policy
  rotation_policy_enabled    = true
  rotation_expire_after      = "P180D"  # 180 days
  rotation_time_before_expiry = "P30D"   # Rotate 30 days before expiry

  tags = var.tags
  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

##### Key Vault Keys for CMK ######

# Generate SSH keypair for Azure VMs 
resource "tls_private_key" "xadm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store the PUBLIC key in Key Vault for use with VM creation
resource "azurerm_key_vault_secret" "xadm_ssh_pub" {
  name         = "${var.admin_ssh_key_name}-pub"
  value        = tls_private_key.xadm.public_key_openssh
  key_vault_id = module.core_kv.key_vault_id
  content_type = "ssh-public-key"

  tags = {
    managed_by = "terraform"
  }
}

resource "azurerm_key_vault_secret" "xadm_ssh_priv" {
  name         = "${var.admin_ssh_key_name}-priv"
  value        = tls_private_key.xadm.private_key_pem
  key_vault_id = module.core_kv.key_vault_id
  content_type = "ssh-private-key"

  tags = {
    managed_by = "terraform"
  }
}