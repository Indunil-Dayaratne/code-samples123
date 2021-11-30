resource "azurerm_key_vault" "keyvault" {
    name                        = "${local.key_vault_name}-${var.azure_short_region}-${terraform.workspace}"
    location                    = var.azure_region
    resource_group_name         = azurerm_resource_group.rg.name
    enabled_for_disk_encryption = true
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    sku_name = "standard"
    tags = local.tags

     access_policy {
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = data.azurerm_client_config.current.object_id

        secret_permissions = [
        "get",
        "list",
        "set"
        ]
    }  
}

resource "azurerm_key_vault" "keyvault_dr" {
    count                       =  var.dr_resource_count  // Deploy in case of TEST and PROD
    name                        = "${local.key_vault_name}-${var.azure_short_region_dr}-${terraform.workspace}"
    location                    = var.azure_region_dr
    resource_group_name         = azurerm_resource_group.rg_dr[count.index].name
    enabled_for_disk_encryption = true
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    sku_name = "standard"
    tags = local.tags_dr

     access_policy {
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = data.azurerm_client_config.current.object_id

        secret_permissions = [
        "get",
        "list",
        "set"
        ]
    }  
}

resource "azurerm_key_vault_access_policy" "api_function_app" {
    key_vault_id = azurerm_key_vault.keyvault.id
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = azurerm_function_app.api_function_app.identity[0].principal_id 

    secret_permissions = [
        "get",
        "list",
        "set"
    ]
}

resource "azurerm_key_vault_access_policy" "api_function_app_dr" {
    count        =  var.dr_resource_count  // Deploy in case of TEST and PROD
    key_vault_id = azurerm_key_vault.keyvault_dr[count.index].id
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = azurerm_function_app.api_function_app_dr[count.index].identity[0].principal_id 

    secret_permissions = [
        "get",
        "list",
        "set"
    ]
}

resource "azurerm_key_vault_access_policy" "web_app" {
    key_vault_id = azurerm_key_vault.keyvault.id
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = azurerm_app_service.web_app.identity[0].principal_id 

    secret_permissions = [
        "get",
        "list",
        "set"
    ]
}

resource "azurerm_key_vault_access_policy" "web_app_kv_dr" {
    count        =  var.dr_resource_count  // Deploy in case of TEST and PROD
    key_vault_id = azurerm_key_vault.keyvault_dr[count.index].id
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = azurerm_app_service.web_app_dr[count.index].identity[0].principal_id 

    secret_permissions = [
        "get",
        "list",
        "set"
    ]    
}

data "azuread_application" "beas_func" {
    name = "beas-func-${terraform.workspace}"
}

resource "azurerm_key_vault_secret" "beas_client_key" {
    name                        = "BeasClientId"
    value                       = data.azuread_application.beas_func.application_id
    key_vault_id                = azurerm_key_vault.keyvault.id
    depends_on   = [azurerm_key_vault_access_policy.web_app,azurerm_key_vault_access_policy.api_function_app]
}

resource "azurerm_key_vault_secret" "beas_client_key_dr" {
    count                       =  var.dr_resource_count  // Deploy in case of TEST and PROD
    name                        = "BeasClientId"
    value                       = data.azuread_application.beas_func.application_id
    key_vault_id                = azurerm_key_vault.keyvault_dr[count.index].id
    depends_on   = [azurerm_key_vault_access_policy.web_app_kv_dr,azurerm_key_vault_access_policy.api_function_app_dr]
}

resource "azurerm_key_vault_secret" "cosmos_account_key" {
    name                        = "CosmosAccountPrimaryKey"
    value                       = data.azurerm_cosmosdb_account.cosmosdb.primary_master_key
    key_vault_id                = azurerm_key_vault.keyvault.id
     depends_on   = [azurerm_key_vault_access_policy.web_app,azurerm_key_vault_access_policy.api_function_app]
}

resource "azurerm_key_vault_secret" "cosmos_account_key_dr" {
    count                       =  var.dr_resource_count  // Deploy in case of TEST and PROD
    name                        = "CosmosAccountPrimaryKey"
    value                       = data.azurerm_cosmosdb_account.cosmosdb.primary_master_key
    key_vault_id                = azurerm_key_vault.keyvault_dr[count.index].id
     depends_on   = [azurerm_key_vault_access_policy.web_app_kv_dr,azurerm_key_vault_access_policy.api_function_app_dr]
}