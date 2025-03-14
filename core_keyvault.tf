module "core_kv" {
  source                          = "github.com/Coalfire-CF/terraform-azurerm-key-vault?ref=v1.0.2"
  diag_log_analytics_id           = azurerm_log_analytics_workspace.core-la.id
  kv_name                         = local.key_vault_name
  resource_group_name             = var.core_rg_name
  location                        = var.location
  tenant_id                       = var.tenant_id
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  regional_tags                   = var.regional_tags
  global_tags                     = var.global_tags
  tags = {
    Plane = "Core"
  }
  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    virtual_network_subnet_ids = []
    ip_rules                   = var.cidrs_for_remote_access
  }

  depends_on = [azurerm_resource_group.core]
}

resource "azurerm_key_vault_key" "ad-cmk" {
  # checkov:skip=CKV_AZURE_112: HSM backed Key Vault keys are not required.
  name         = "ad-cmk"
  key_vault_id = module.core_kv.key_vault_id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

resource "azurerm_key_vault_key" "ars-cmk" {
  # checkov:skip=CKV_AZURE_112: HSM backed Key Vault keys are not required.
  name         = "ars-cmk"
  key_vault_id = module.core_kv.key_vault_id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

resource "azurerm_key_vault_key" "flowlog-cmk" {
  # checkov:skip=CKV_AZURE_112: HSM backed Key Vault keys are not required.
  name         = "flowlog-cmk"
  key_vault_id = module.core_kv.key_vault_id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

resource "azurerm_key_vault_key" "install-cmk" {
  # checkov:skip=CKV_AZURE_112: HSM backed Key Vault keys are not required.
  name         = "install-cmk"
  key_vault_id = module.core_kv.key_vault_id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

resource "azurerm_key_vault_key" "tstate-cmk" {
  # checkov:skip=CKV_AZURE_112: HSM backed Key Vault keys are not required.
  name         = "tstate-cmk"
  key_vault_id = module.core_kv.key_vault_id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

resource "azurerm_key_vault_key" "law_queries-cmk" {
  # checkov:skip=CKV_AZURE_112: HSM backed Key Vault keys are not required.
  name         = "law-queries-cmk"
  key_vault_id = module.core_kv.key_vault_id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

resource "azurerm_key_vault_key" "cloudshell-cmk" {
  # checkov:skip=CKV_Azure_112:HSM backed Key Vault keys are not required.
  name         = "cloudshell-cmk"
  key_vault_id = module.core_kv.key_vault_id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

resource "azurerm_key_vault_key" "docs-cmk" {
  # checkov:skip=CKV_Azure_112:HSM backed Key Vault keys are not required.
  name         = "docs-cmk"
  key_vault_id = module.core_kv.key_vault_id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

resource "azurerm_key_vault_key" "avd-cmk" {
  # checkov:skip=CKV_Azure_112:HSM backed Key Vault keys are not required.
  name         = "avd-cmk"
  key_vault_id = module.core_kv.key_vault_id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_role_assignment.core_kv_administrator]
}

# Create SSH keys for xadm and store in AKV
resource "tls_private_key" "xadm" {
  algorithm = "RSA"
}

resource "azurerm_key_vault_secret" "xadm_ssh" {
  name         = var.admin_ssh_key_name
  value        = base64encode(tls_private_key.xadm.private_key_openssh)
  key_vault_id = module.core_kv.key_vault_id
  content_type = "ssh-key"
}
