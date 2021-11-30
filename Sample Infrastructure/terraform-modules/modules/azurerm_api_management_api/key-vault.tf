data "azurerm_key_vault" "swagger_keyvault" {
    name                        = var.swagger_api.key_vault_name
    resource_group_name         = var.swagger_api.resource_group_name
}

resource "azurerm_key_vault_secret" "swagger_url_secret" {
    name          = "${var.swagger_api.entity_name}-SwaggerUrl"
    value         = var.swagger_api.swagger_url
    key_vault_id  = data.azurerm_key_vault.swagger_keyvault.id
}

resource "azurerm_key_vault_secret" "client_id_secret" {
    name          = "${var.swagger_api.entity_name}-ClientId"
    value         = var.swagger_api.client_id
    key_vault_id  = data.azurerm_key_vault.swagger_keyvault.id
}
