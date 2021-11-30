data "azurerm_key_vault" "kv" {
    name = var.KeyVault.Name
    resource_group_name = var.KeyVault.ResourceGroup
}

data "azurerm_key_vault_secret" "domain_join_password" {
    key_vault_id = data.azurerm_key_vault.kv.id
    name = "DomainJoin"
}

resource "random_password" "sql_vm_admin_password" {
    length              = 30
    min_upper           = 1
    min_lower           = 1
    min_numeric         = 1
    min_special         = 1
}

resource "azurerm_key_vault_secret" "sqlvm_admin_password" {
    name                = "${local.tags.app}-sqlvm-adminpassword-${terraform.workspace}"
    key_vault_id        = data.azurerm_key_vault.kv.id
    value               = random_password.sql_vm_admin_password.result
    tags                = local.tags
}

resource "azurerm_key_vault_secret" "spgatewayapp_clientid" {
    key_vault_id = data.azurerm_key_vault.kv.id
    name = "${local.tags.app}-sharepoint-dms-sponlinegateway-clientid-${terraform.workspace}"
    value = azuread_application.gateway_app_registration.application_id
}

resource "azurerm_key_vault_secret" "spgatewayapp_secret" {
    key_vault_id = data.azurerm_key_vault.kv.id
    name = "${local.tags.app}-sponlinegateway-acceptancetestexecution-secret-${terraform.workspace}"
    value = random_password.serviceapp_secret.result
}

data "azurerm_key_vault_secret" "sp_cert_secret" {
    name = "sharepoint-credentials-certificate-password"
    key_vault_id = data.azurerm_key_vault.kv.id
}