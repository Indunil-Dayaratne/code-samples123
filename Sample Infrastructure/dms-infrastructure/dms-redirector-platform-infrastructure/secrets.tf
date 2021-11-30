data "azurerm_key_vault" "kv" {
    name = var.KeyVault.Name
    resource_group_name = var.KeyVault.ResourceGroup
}

data "azurerm_key_vault_secret" "sp_cert_secret" {
    name = "sharepoint-credentials-certificate-password"
    key_vault_id = data.azurerm_key_vault.kv.id
}