data "azurerm_key_vault" "keyvault" {
    name                        = "eclipse-update-kv-${terraform.workspace}"
    resource_group_name         = data.azurerm_resource_group.rg.name
}

resource "azurerm_key_vault" "keyvault_dr" {
    name                        = "eclipse-upd-kv-${var.azure_short_region_dr}-${terraform.workspace}"
    location                    = azurerm_resource_group.rg_dr.location
    resource_group_name         = azurerm_resource_group.rg_dr.name
    enabled_for_disk_encryption = true
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    sku_name = "standard"
    tags = local.tags_dr
}

data "azuread_application" "beas_func" {
    name = "beas-func-${terraform.workspace}"
}

data "azuread_application" "britcache_func" {
    name = "britcache-api-${terraform.workspace}"
}

resource "azurerm_key_vault_access_policy" "mapper_func" {
    key_vault_id = data.azurerm_key_vault.keyvault.id
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = azurerm_function_app.mapper_func.identity[0].principal_id 

    secret_permissions = [
        "get",
        "list",
        "set"
    ]
}

resource "azurerm_key_vault_access_policy" "validator_func" {
    key_vault_id = data.azurerm_key_vault.keyvault.id
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = azurerm_function_app.validator_func.identity[0].principal_id 

    secret_permissions = [
        "get",
        "list",
        "set"
    ]
}

resource "azurerm_key_vault_access_policy" "validator_func_dr" {
    key_vault_id = azurerm_key_vault.keyvault_dr.id
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = azurerm_function_app.validator_func_dr.identity[0].principal_id 

    secret_permissions = [
        "get",
        "list",
        "set"
    ]
}

resource "azurerm_key_vault_access_policy" "api_func" {
    key_vault_id = data.azurerm_key_vault.keyvault.id
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = azurerm_function_app.api_func.identity[0].principal_id 

    secret_permissions = [
        "get",
        "list",
        "set"
    ]
}

resource "azurerm_key_vault_access_policy" "api_func_dr" {
    key_vault_id = azurerm_key_vault.keyvault_dr.id
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = azurerm_function_app.api_func_dr.identity[0].principal_id 

    secret_permissions = [
        "get",
        "list",
        "set"
    ]
}

resource "azurerm_key_vault_access_policy" "spn_dr" {
    key_vault_id = azurerm_key_vault.keyvault_dr.id
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id  

    secret_permissions = [
        "get",
        "list",
        "set"
    ]
}

resource "azurerm_key_vault_secret" "BeasClientId" {
    name          = "BeasClientId"
    value         = data.azuread_application.beas_func.application_id
    key_vault_id  = data.azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "BeasClientId_dr" {
    name          = "BeasClientId"
    value         = data.azuread_application.beas_func.application_id
    key_vault_id  = azurerm_key_vault.keyvault_dr.id
}

resource "azurerm_key_vault_secret" "BritcacheClientId" {
    name          = "BritcacheClientId"
    value         = data.azuread_application.britcache_func.application_id
    key_vault_id  = data.azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "BritcacheClientId_dr" {
    name          = "BritcacheClientId"
    value         = data.azuread_application.britcache_func.application_id
    key_vault_id  = azurerm_key_vault.keyvault_dr.id
}

resource "azurerm_key_vault_secret" "ValidatorClientId" {
    name          = "ValidatorClientId"
    value         =  azuread_application.val_aad.application_id
    key_vault_id  = data.azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "ValidatorClientId_dr" {
    name          = "ValidatorClientId"
    value         =  azuread_application.val_aad.application_id
    key_vault_id  = azurerm_key_vault.keyvault_dr.id
}

resource "azurerm_key_vault_secret" "esb_storage_connection_string" {
    name          = "EsbStorageConnectionString"
    value         = data.azurerm_storage_account.esbstorage.primary_connection_string
    key_vault_id  = data.azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "esb_service_bus_connection_string" {
    name          = "EsbServiceBusConnectionString"
    value         = data.azurerm_servicebus_namespace.esb_svcbus.default_primary_connection_string
    key_vault_id  = data.azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "esb_storage_connection_string_dr" {
    name          = "EsbStorageConnectionString"
    value         = data.azurerm_storage_account.esbstorage.primary_connection_string
    key_vault_id  = azurerm_key_vault.keyvault_dr.id
}

resource "azurerm_key_vault_secret" "esb_service_bus_connection_string_dr" {
    name          = "EsbServiceBusConnectionString"
    value         = data.azurerm_servicebus_namespace.esb_svcbus.default_primary_connection_string
    key_vault_id  = azurerm_key_vault.keyvault_dr.id
}