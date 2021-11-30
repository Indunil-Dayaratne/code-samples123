data "azurerm_storage_account" "funcstorage" {
  name                     = var.common_shared.storage_account
  resource_group_name      = var.common_shared.resource_group
}

data "azuread_application" "risk_api_func" {
    name = "eclipse-api-func-${terraform.workspace}"
}

data "azuread_application" "risk_validator_api_func" {
    name = "eclipse-risk-validator-func-${terraform.workspace}"
}

data "azuread_application" "britcache_api_func" {
    name = "britcache-api-${terraform.workspace}"
}

data "azurerm_storage_account" "funcstorage_dr" {
  name                     = var.common_shared_dr.storage_account
  resource_group_name      = var.common_shared_dr.resource_group
}

data "azurerm_app_service_plan" "appplan" {
    name = var.shared.app_service
    resource_group_name = var.shared.resource_group
}

data "azurerm_app_service_plan" "appplan_dr" {
    name = var.shared_dr.app_service
    resource_group_name = var.shared_dr.resource_group
}

resource "azurerm_app_service_plan" "consumption_appplan" {
  name                = "${local.app_service_plan}-${var.azure_short_region}-${terraform.workspace}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"
  tags                = local.tags
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "api_function_app" {
    name                       = "${local.api_func_name}-${var.azure_short_region}-${terraform.workspace}"
    location                   = var.azure_region
    resource_group_name        = azurerm_resource_group.rg.name
    app_service_plan_id        = azurerm_app_service_plan.consumption_appplan.id
    storage_account_name       = data.azurerm_storage_account.funcstorage.name
    storage_account_access_key = data.azurerm_storage_account.funcstorage.primary_access_key
    version                    = "~3"
    identity { 
        type = "SystemAssigned" 
    }  
    https_only                = true
    tags                      = local.tags
    site_config { 
        use_32_bit_worker_process = false
        cors {
            allowed_origins = var.cors
        }
    }
    auth_settings {
        enabled = true
        default_provider = "AzureActiveDirectory"
        unauthenticated_client_action = "RedirectToLoginPage"
        issuer = "https://sts.windows.net/8cee18df-5e2a-4664-8d07-0566ffea6dcd"
        active_directory {
            client_id = azuread_application.func_aad.application_id
            allowed_audiences = ["https://${azuread_application.func_aad.name}.azurewebsites.net","https://${azuread_application.func_aad.name}.azurewebsites.net/.auth/login/aad/callback"]
        }
    }
    app_settings = {
        APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.appins.instrumentation_key
        AzureWebJobsDashboard = data.azurerm_storage_account.funcstorage.primary_connection_string
        AzureWebJobsStorage = data.azurerm_storage_account.funcstorage.primary_connection_string
        FUNCTIONS_EXTENSION_VERSION = "~3"
        FUNCTIONS_WORKER_RUNTIME = "dotnet"
        KeyVaultName = azurerm_key_vault.keyvault.name
        KEYVAULT_RESOURCEID = "${azurerm_key_vault.keyvault.vault_uri}secrets/"
        audience = "https://${azuread_application.func_aad.name}.azurewebsites.net"
        ValidIssuers = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0,https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/"
        OpenIdConfigurationEndPoint = "https://login.microsoftonline.com/britinsurance.com/v2.0/.well-known/openid-configuration"
        tenantid = data.azurerm_client_config.current.tenant_id
        "beas:BaseUrl" = var.beas_base_url
        "beas:ApplicationName" = "Opus"
        "beas:ApplicationArea" = "UWDashboard"
        "beas:ApplicationRole" = "Entry-Sheet"
        "EclipseRisk:BaseUrl" = var.eclipse_riskapi_base_url
        "EclipseRisk:ClientId" =  data.azuread_application.risk_api_func.application_id
        "EclipseRiskValidation:BaseUrl" = var.eclipse_risk_validation_api_base_url
        "EclipseRiskValidation:ClientId" =  data.azuread_application.risk_validator_api_func.application_id
        "britCache:BaseURL" = var.britcache_api_base_url
        "britCache:ClientId" =  data.azuread_application.britcache_api_func.application_id
        "cosmos:AccountPrimaryKey" = "cosmos-account-primary-key"
        "cosmos:DatabaseEndpoint" = var.cosmos_database_endpoint_url
        "cosmos:DatabaseName" = "shared"
        "cosmos:HistoryDataContainerName" = "entry-sheet-eclipse-history-${terraform.workspace}"
        "cosmos:LatestDataContainerName" = "entry-sheet-eclipse-${terraform.workspace}"
    } 
}

resource "azurerm_app_service_plan" "consumption_appplan_dr" {
  count               = var.dr_resource_count  // Deploy in case of TEST and PROD
  name                = "${local.app_service_plan}-${var.azure_short_region_dr}-${terraform.workspace}"
  location            = azurerm_resource_group.rg_dr[count.index].location
  resource_group_name = azurerm_resource_group.rg_dr[count.index].name
  kind                = "FunctionApp"
  tags                = local.tags_dr
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}


resource "azurerm_function_app" "api_function_app_dr" {
    count                      = var.dr_resource_count  // Deploy in case of TEST and PROD
    name                       = "${local.api_func_name}-${var.azure_short_region_dr}-${terraform.workspace}"
    location                   = var.azure_region_dr
    resource_group_name        = azurerm_resource_group.rg_dr[count.index].name
    app_service_plan_id        = azurerm_app_service_plan.consumption_appplan_dr[count.index].id
    storage_account_name       = data.azurerm_storage_account.funcstorage_dr.name
    storage_account_access_key = data.azurerm_storage_account.funcstorage_dr.primary_access_key
    version                    = "~3"
    identity { 
        type = "SystemAssigned" 
    }  
    https_only                = true
    tags                      = local.tags
    site_config { 
        use_32_bit_worker_process = false
        cors {
            allowed_origins = var.cors
        }
    }
    auth_settings {
        enabled = true
        default_provider = "AzureActiveDirectory"
        unauthenticated_client_action = "RedirectToLoginPage"
        issuer = "https://sts.windows.net/8cee18df-5e2a-4664-8d07-0566ffea6dcd"
        active_directory {
            client_id = azuread_application.func_aad.application_id
            allowed_audiences = ["https://${azuread_application.func_aad.name}.azurewebsites.net","https://${azuread_application.func_aad.name}.azurewebsites.net/.auth/login/aad/callback"]
        }
    }
    app_settings = {
        APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.appins_dr[count.index].instrumentation_key
        AzureWebJobsDashboard = data.azurerm_storage_account.funcstorage_dr.primary_connection_string
        AzureWebJobsStorage = data.azurerm_storage_account.funcstorage_dr.primary_connection_string
        FUNCTIONS_EXTENSION_VERSION = "~3"
        FUNCTIONS_WORKER_RUNTIME = "dotnet"
        KeyVaultName = azurerm_key_vault.keyvault_dr[count.index].name
        KEYVAULT_RESOURCEID = "${azurerm_key_vault.keyvault_dr[count.index].vault_uri}secrets/"
        audience = "https://${azuread_application.func_aad.name}.azurewebsites.net"
        ValidIssuers = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0,https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/"
        OpenIdConfigurationEndPoint = "https://login.microsoftonline.com/britinsurance.com/v2.0/.well-known/openid-configuration"
        tenantid = data.azurerm_client_config.current.tenant_id
        "beas:BaseUrl" = var.beas_base_url
        "beas:ApplicationName" = "Opus"
        "beas:ApplicationArea" = "UWDashboard"
        "beas:ApplicationRole" = "Entry-Sheet"
        "EclipseRisk:BaseUrl" = var.eclipse_riskapi_base_url
        "EclipseRisk:ClientId" =  data.azuread_application.risk_api_func.application_id
        "EclipseRiskValidation:BaseUrl" = var.eclipse_risk_validation_api_base_url
        "EclipseRiskValidation:ClientId" =  data.azuread_application.risk_validator_api_func.application_id
        "britCache:BaseURL" = var.britcache_api_base_url
        "britCache:ClientId" =  data.azuread_application.britcache_api_func.application_id
        "cosmos:AccountPrimaryKey" = "cosmos-account-primary-key"
        "cosmos:DatabaseEndpoint" = var.cosmos_database_endpoint_url
        "cosmos:DatabaseName" = "shared"
        "cosmos:HistoryDataContainerName" = "entry-sheet-eclipse-history-${terraform.workspace}"
        "cosmos:LatestDataContainerName" = "entry-sheet-eclipse-${terraform.workspace}"
    }
}

