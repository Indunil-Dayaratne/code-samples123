resource "azurerm_app_service" "web_app" {
    name                = "${local.web_app_name}-${var.azure_short_region}-${terraform.workspace}"
    location            = var.azure_region
    resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = data.azurerm_app_service_plan.appplan.id
    https_only          = true
    identity { 
        type = "SystemAssigned" 
    }
    tags     = local.tags
    client_affinity_enabled = false

    site_config {
        always_on = true
        http2_enabled = true
        default_documents = ["index.html"]
        cors {
            allowed_origins = var.cors
            support_credentials = true 
        }
        use_32_bit_worker_process = false
    }

    auth_settings {
        enabled = true        
        issuer  = "https://sts.windows.net/8cee18df-5e2a-4664-8d07-0566ffea6dcd"
        token_store_enabled = true
        default_provider = "AzureActiveDirectory"
        unauthenticated_client_action = "AllowAnonymous"
        active_directory {
            client_id = azuread_application.web_app_aad.application_id           
        }
    }
    app_settings = {
         APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.appins.instrumentation_key
        "AzureAd:Audience"= "https://${azuread_application.web_app_aad.name}.azurewebsites.net",
        "AzureAd:ValidIssuers"= "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0,https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/"
        "AzureAd:OpenIdConfigurationEndPoint"= "https://login.microsoftonline.com/britinsurance.com/v2.0/.well-known/openid-configuration"
        "Settings:KeyVaultResourceId"=azurerm_key_vault.keyvault.vault_uri
        "Settings:CommentsApplicationName" = "Opus"
        "Settings:CommentsApplicationAreaName" = "ClaimsWatchlist"
        "Settings:Beas:BaseUrl"=var.beas_base_url
        "Settings:Beas:ApplicationName"="Opus"
        "Settings:Beas:ApplicationArea"="UWDashboard"
        "Settings:Beas:ApplicationRole"="Claims-Watchlist"
        "Settings:Beas:ApplicationNameInternal" = "ClaimsWatchlist"       
        "Settings:Beas:ApplicationAreaInternal" = "ClaimsWatchlist"
        "Settings:Beas:ApplicationRoleReadOnly" = "ReadOnly"
        "Settings:Beas:ApplicationRoleWrite" = "ReadWrite"
        "Settings:RootUrl"="https://${local.web_app_name}-${var.azure_short_region}-${terraform.workspace}.azurewebsites.net"
        "Settings:ClaimsWatchlistApi:BaseUrl"="https://${local.api_func_name}-${var.azure_short_region}-${terraform.workspace}.azurewebsites.net/api"
        "Settings:ClaimsWatchlistApi:ClientId"=azuread_application.func_aad.application_id
        "Settings:ClaimsWatchlistApi:Scope"="https://${local.func_aad_name}-${terraform.workspace}.azurewebsites.net/user_impersonation"
        "Settings:UserPreferences:ClaimsWatchlistPreferenceKey" = var.user_preferences.preference_key
        "Settings:UserPreferences:ClaimsWatchlistPreferenceKeyId" = var.user_preferences.preference_key_id
        "Settings:UserPreferences:ClaimsWatchlistOpenItemsGridPreferenceKey" = var.user_preferences.grid_preference_key
        "Settings:UserPreferences:ClaimsWatchlistOpenItemsGridPreferenceKeyId" = var.user_preferences.grid_preference_key_id
    }
}

resource "azurerm_app_service" "web_app_dr" {
    count               =  var.dr_resource_count  // Deploy in case of TEST and PROD
    name                = "${local.web_app_name}-${var.azure_short_region_dr}-${terraform.workspace}"
    location            = var.azure_region_dr
    resource_group_name = azurerm_resource_group.rg_dr[count.index].name
    app_service_plan_id = data.azurerm_app_service_plan.appplan_dr.id
    https_only          = true
    identity { 
        type = "SystemAssigned" 
    }
    tags     = local.tags_dr
    client_affinity_enabled = false

    site_config {
        always_on = true
        http2_enabled = true
        default_documents = ["index.html"]
        cors {
            allowed_origins = var.cors
            support_credentials = true 
        }
        use_32_bit_worker_process = false
    }

    auth_settings {
        enabled = "true"
        issuer  = "https://sts.windows.net/8cee18df-5e2a-4664-8d07-0566ffea6dcd"
        token_store_enabled = true
        default_provider = "AzureActiveDirectory"
        unauthenticated_client_action = "AllowAnonymous"
        active_directory {
            client_id = azuread_application.web_app_aad.application_id
        }
    }

    app_settings = {
         APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.appins_dr[count.index].instrumentation_key
        "AzureAd:Audience"= "https://${azuread_application.web_app_aad.name}.azurewebsites.net",
        "AzureAd:ValidIssuers"= "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0,https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/"
        "AzureAd:OpenIdConfigurationEndPoint"= "https://login.microsoftonline.com/britinsurance.com/v2.0/.well-known/openid-configuration"
        "Settings:KeyVaultResourceId"=azurerm_key_vault.keyvault_dr[count.index].vault_uri
        "Settings:CommentsApplicationName" = "Opus"
        "Settings:CommentsApplicationAreaName" = "ClaimsWatchlist"
        "Settings:Beas:BaseUrl"=var.beas_base_url
        "Settings:Beas:ApplicationName"="Opus"
        "Settings:Beas:ApplicationArea"="UWDashboard"
        "Settings:Beas:ApplicationRole"="Claims-Watchlist"
        "Settings:Beas:ApplicationNameInternal" = "ClaimsWatchlist"       
        "Settings:Beas:ApplicationAreaInternal" = "ClaimsWatchlist"
        "Settings:Beas:ApplicationRoleReadOnly" = "ReadOnly"
        "Settings:Beas:ApplicationRoleWrite" = "ReadWrite"
        "Settings:RootUrl"="https://${local.web_app_name}-${var.azure_short_region_dr}-${terraform.workspace}.azurewebsites.net"
        "Settings:ClaimsWatchlistApi:BaseUrl"="https://${local.api_func_name}-${var.azure_short_region_dr}-${terraform.workspace}.azurewebsites.net/api"
        "Settings:ClaimsWatchlistApi:ClientId"=azuread_application.func_aad.application_id
        "Settings:ClaimsWatchlistApi:Scope"="https://${local.func_aad_name}-${terraform.workspace}.azurewebsites.net/user_impersonation"
        "Settings:UserPreferences:ClaimsWatchlistPreferenceKey" = var.user_preferences.preference_key
        "Settings:UserPreferences:ClaimsWatchlistPreferenceKeyId" = var.user_preferences.preference_key_id
    
    }
}
