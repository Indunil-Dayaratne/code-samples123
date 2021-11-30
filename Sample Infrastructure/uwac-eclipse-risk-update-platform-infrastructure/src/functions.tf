data "azurerm_storage_account" "funcstorage" {
  name                     = var.common_shared.storage_account
  resource_group_name      = var.common_shared.resource_group
}

data "azurerm_storage_account" "funcstorage_dr" {
  name                     = var.common_shared_dr.storage_account
  resource_group_name      = var.common_shared_dr.resource_group
}
data "azurerm_app_service_plan" "appplan" {
    name = var.shared.app_service_plan
    resource_group_name = var.shared.resource_group
}

data "azurerm_app_service_plan" "appplan_dr" {
    name = var.shared_dr.app_service_plan
    resource_group_name = var.shared_dr.resource_group
}

data "azurerm_subnet" "appservice_subnet" {
    name = var.subnet.name
    resource_group_name = var.subnet.resource_group
    virtual_network_name = var.subnet.vnet_name
}

data "azurerm_subnet" "appservice_subnet_dr" {
    name = var.subnet_dr.name
    resource_group_name = var.subnet_dr.resource_group
    virtual_network_name = var.subnet_dr.vnet_name
}

resource "azurerm_app_service_plan" "consumption_appplan" {
  name                = "${local.app_service_plan}-${var.azure_short_region}-${terraform.workspace}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  kind                = "FunctionApp"
  tags                = local.tags
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "validator_func" {
  name                       = "${local.validator_func_name}-${var.azure_short_region}-${terraform.workspace}"
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.consumption_appplan.id
  storage_account_name       = data.azurerm_storage_account.funcstorage.name
  storage_account_access_key = data.azurerm_storage_account.funcstorage.primary_access_key
  version                    = "~3"
  identity { 
    type = "SystemAssigned" 
  }  
  https_only                 = true
  tags                       = local.tags
  site_config { 
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
      client_id = azuread_application.val_aad.application_id
       allowed_audiences = ["https://${azuread_application.val_aad.name}.azurewebsites.net","https://${azuread_application.val_aad.name}.azurewebsites.net/.auth/login/aad/callback"]
    }
  }  
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = data.azurerm_application_insights.appins.instrumentation_key
    AzureWebJobsDashboard = data.azurerm_storage_account.funcstorage.primary_connection_string
    AzureWebJobsStorage = data.azurerm_storage_account.funcstorage.primary_connection_string
    FUNCTIONS_EXTENSION_VERSION = "~3"
    FUNCTIONS_WORKER_RUNTIME = "dotnet"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    KeyVaultName = data.azurerm_key_vault.keyvault.name
    audience = "https://${local.validator_func_name}-${var.azure_short_region}-${terraform.workspace}.azurewebsites.net"
    ValidIssuers = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0,https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/"
    OpenIdConfigurationEndPoint = "https://login.microsoftonline.com/britinsurance.com/v2.0/.well-known/openid-configuration"
    tenantid = data.azurerm_client_config.current.tenant_id
    "Beas:BaseUrl" = "https://${local.beas_app_name}.azurewebsites.net/api"
    "Beas:ApplicationName" = "EclipseValidator"
    "Beas:ApplicationArea" = "EclipseValidator"
    "Beas:ApplicationRole" = "BritInternal"
    "Britcache:BaseUrl" = "https://${local.britcache_app_name}.azurewebsites.net/api/v2"
    "Eclipse:BaseUrl" = var.eclipse_base_url
    "ServiceAccountName"= var.service_account_name
  }
}

resource "azurerm_app_service_plan" "consumption_appplan_dr" {
  name                = "${local.app_service_plan}-${var.azure_short_region_dr}-${terraform.workspace}"
  location            = azurerm_resource_group.rg_dr.location
  resource_group_name = azurerm_resource_group.rg_dr.name
  kind                = "FunctionApp"
  tags                = local.tags_dr
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "validator_func_dr" {
  name                       = "${local.validator_func_name}-${var.azure_short_region_dr}-${terraform.workspace}"
  location                   = azurerm_resource_group.rg_dr.location
  resource_group_name        = azurerm_resource_group.rg_dr.name
  app_service_plan_id        = azurerm_app_service_plan.consumption_appplan_dr.id
  storage_account_name       = data.azurerm_storage_account.funcstorage_dr.name
  storage_account_access_key = data.azurerm_storage_account.funcstorage_dr.primary_access_key
  version                    = "~3"
  identity { 
    type = "SystemAssigned" 
  }  
  https_only                 = true
  tags                       = local.tags_dr
  site_config { 
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
      client_id = azuread_application.val_aad.application_id
      allowed_audiences = ["https://${azuread_application.val_aad.name}.azurewebsites.net","https://${azuread_application.val_aad.name}.azurewebsites.net/.auth/login/aad/callback"]
    }
  }  
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.appins_dr.instrumentation_key
    AzureWebJobsDashboard = data.azurerm_storage_account.funcstorage_dr.primary_connection_string
    AzureWebJobsStorage = data.azurerm_storage_account.funcstorage_dr.primary_connection_string
    FUNCTIONS_EXTENSION_VERSION = "~3"
    FUNCTIONS_WORKER_RUNTIME = "dotnet"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    KeyVaultName = azurerm_key_vault.keyvault_dr.name
    audience = "https://${local.validator_func_name}-${var.azure_short_region_dr}-${terraform.workspace}.azurewebsites.net"
    ValidIssuers = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0,https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/"
    OpenIdConfigurationEndPoint = "https://login.microsoftonline.com/britinsurance.com/v2.0/.well-known/openid-configuration"
    tenantid = data.azurerm_client_config.current.tenant_id
    "Beas:BaseUrl" = "https://${local.beas_app_name}.azurewebsites.net/api"
      "Beas:ApplicationName" = "EclipseValidator"
    "Beas:ApplicationArea" = "EclipseValidator"
    "Beas:ApplicationRole" = "BritInternal"
    "Britcache:BaseUrl" = "https://${local.britcache_app_name}.azurewebsites.net/api/v2"
    "Eclipse:BaseUrl" = var.eclipse_base_url
    "ServiceAccountName"= var.service_account_name
  }
}

resource "azurerm_function_app" "mapper_func" {
  name                       = local.mapper_func_name
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  app_service_plan_id        = data.azurerm_app_service_plan.appplan.id
  storage_account_name       = data.azurerm_storage_account.funcstorage.name
  storage_account_access_key = data.azurerm_storage_account.funcstorage.primary_access_key
  version                    = "~3"
  identity  { 
    type = "SystemAssigned" 
  }  
  https_only                 = true
  tags                       = local.tags
  site_config { 
    always_on = true
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
      client_id = azuread_application.map_aad.application_id
    }
  }  
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = data.azurerm_application_insights.appins.instrumentation_key
    AzureWebJobsDashboard = data.azurerm_storage_account.funcstorage.primary_connection_string
    AzureWebJobsStorage = data.azurerm_storage_account.funcstorage.primary_connection_string
    FUNCTIONS_EXTENSION_VERSION = "~3"
    FUNCTIONS_WORKER_RUNTIME = "dotnet"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    KeyVaultName = data.azurerm_key_vault.keyvault.name,
    "Esb:EclipseRiskUpdateInQueue" = "eclipse-risk-update-in"
    "Esb:EclipsePolicyInQueue" = "eclipse-policy-in"
    "Esb:ServiceBusConnectionString" = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.keyvault.vault_uri}secrets/${azurerm_key_vault_secret.esb_service_bus_connection_string.name}/${azurerm_key_vault_secret.esb_service_bus_connection_string.version})"
    "Notification:ClientId" = data.azuread_application.notify_aad.application_id,
    "Notification:BaseUrl" = "https://${local.notify_func_name}.azurewebsites.net/api/",
    "Validation:ClientId" = azuread_application.val_aad.application_id,
    "Validation:BaseUrl" = "https://${local.validator_func_name}-${var.azure_short_region}-${terraform.workspace}.azurewebsites.net/api/",
    "Eclipse:BaseUrl" = var.eclipse_base_url,
    "ServiceAccountName"= var.service_account_name
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "mapper_vnet" {
  app_service_id = azurerm_function_app.mapper_func.id
  subnet_id      = data.azurerm_subnet.appservice_subnet.id
}

resource "azurerm_function_app" "api_func" {
  name                       = "${local.api_func_name}-${var.azure_short_region}-${terraform.workspace}"
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  app_service_plan_id        = data.azurerm_app_service_plan.appplan.id
  storage_account_name       = data.azurerm_storage_account.funcstorage.name
  storage_account_access_key = data.azurerm_storage_account.funcstorage.primary_access_key
  version                    = "~3"
  identity { 
    type = "SystemAssigned" 
  }  
  https_only                 = true
  tags                       = local.tags
  site_config { 
    always_on = true
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
      client_id = azuread_application.api_aad.application_id
      allowed_audiences = ["https://${azuread_application.api_aad.name}.azurewebsites.net","https://${azuread_application.api_aad.name}.azurewebsites.net/.auth/login/aad/callback"]
    }
  }  
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = data.azurerm_application_insights.appins.instrumentation_key
    AzureWebJobsDashboard = data.azurerm_storage_account.funcstorage.primary_connection_string
    AzureWebJobsStorage = data.azurerm_storage_account.funcstorage.primary_connection_string
    FUNCTIONS_EXTENSION_VERSION = "~3"
    FUNCTIONS_WORKER_RUNTIME = "dotnet"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    KEY_VAULT_NAME = data.azurerm_key_vault.keyvault.name
    audience = "https://${local.api_func_name}-${var.azure_short_region}-${terraform.workspace}.azurewebsites.net"
    ValidIssuers = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0,https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/"
    OpenIdConfigurationEndPoint = "https://login.microsoftonline.com/britinsurance.com/v2.0/.well-known/openid-configuration"
    tenantid = data.azurerm_client_config.current.tenant_id
    "beas:BaseUrl" = "https://${local.beas_app_name}.azurewebsites.net/api"
    "beas:ApplicationName" = "Opus"
    "beas:ApplicationArea" = "UWDashboard"
    "beas:ApplicationRole" = "EclipseUpdate"
    "Eclipse:BaseUrl" = var.eclipse_base_url
    "Validation:BaseUrl" = "https://${local.validator_func_name}-${var.azure_short_region}-${terraform.workspace}.azurewebsites.net/api"
    "Esb:EclipseRiskUpdateInQueue" = "eclipse-risk-update-in"
    "ServiceAccountName"= var.service_account_name
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "api_func_vnet" {
  app_service_id = azurerm_function_app.api_func.id
  subnet_id      = data.azurerm_subnet.appservice_subnet.id
}

resource "azurerm_function_app" "api_func_dr" {
  name                       = "${local.api_func_name}-${var.azure_short_region_dr}-${terraform.workspace}"
  location                   = azurerm_resource_group.rg_dr.location
  resource_group_name        = azurerm_resource_group.rg_dr.name
  app_service_plan_id        = data.azurerm_app_service_plan.appplan_dr.id
  storage_account_name       = data.azurerm_storage_account.funcstorage_dr.name
  storage_account_access_key = data.azurerm_storage_account.funcstorage_dr.primary_access_key
  version                    = "~3"
  identity { 
    type = "SystemAssigned" 
  }  
  https_only                 = true
  tags                       = local.tags_dr
  site_config { 
    always_on = true
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
      client_id = azuread_application.api_aad.application_id
      allowed_audiences = ["https://${azuread_application.api_aad.name}.azurewebsites.net","https://${azuread_application.api_aad.name}.azurewebsites.net/.auth/login/aad/callback"]
    }
  }  
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.appins_dr.instrumentation_key
    AzureWebJobsDashboard = data.azurerm_storage_account.funcstorage_dr.primary_connection_string
    AzureWebJobsStorage = data.azurerm_storage_account.funcstorage_dr.primary_connection_string
    FUNCTIONS_EXTENSION_VERSION = "~3"
    FUNCTIONS_WORKER_RUNTIME = "dotnet"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
    WEBSITE_RUN_FROM_PACKAGE = "1"
    KEY_VAULT_NAME = azurerm_key_vault.keyvault_dr.name
    audience = "https://${local.api_func_name}-${var.azure_short_region}-${terraform.workspace}.azurewebsites.net"
    ValidIssuers = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0,https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/"
    OpenIdConfigurationEndPoint = "https://login.microsoftonline.com/britinsurance.com/v2.0/.well-known/openid-configuration"
    tenantid = data.azurerm_client_config.current.tenant_id
    "beas:BaseUrl" = "https://${local.beas_app_name}.azurewebsites.net/api"
    "beas:ApplicationName" = "Opus"
    "beas:ApplicationArea" = "UWDashboard"
    "beas:ApplicationRole" = "EclipseUpdate"
    "Eclipse:BaseUrl" = var.eclipse_base_url
    "Validation:BaseUrl" = "https://${local.validator_func_name}-${var.azure_short_region}-${terraform.workspace}.azurewebsites.net/api"
    "Esb:EclipseRiskUpdateInQueue" = "eclipse-risk-update-in"
    "ServiceAccountName"= var.service_account_name
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "api_func_dr_vnet" {
  app_service_id = azurerm_function_app.api_func_dr.id
  subnet_id      = data.azurerm_subnet.appservice_subnet_dr.id
}