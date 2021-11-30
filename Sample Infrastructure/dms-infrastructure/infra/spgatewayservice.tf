data "azurerm_app_service_plan" "shared" {
    name = var.AppServicePlan.Name
    resource_group_name = var.AppServicePlan.ResourceGroup
}

data "azurerm_app_service_plan" "shared_dr" {
    name = var.AppServicePlanDr.Name
    resource_group_name = var.AppServicePlanDr.ResourceGroup
}

resource "azurerm_app_service" "gatewaywebapp" {
    app_service_plan_id = data.azurerm_app_service_plan.shared.id
    name = local.spgateway_webapp_name
    location = data.azurerm_app_service_plan.shared.location
    resource_group_name = azurerm_resource_group.rg.name
    https_only = "true"
    client_affinity_enabled = "true"

    identity {
        type = "SystemAssigned"
    }

    site_config {
        default_documents = ["Default.aspx"]
        dotnet_framework_version = "v4.0"
        ftps_state = "Disabled"
        always_on = "true"
        scm_type = "VSTSRM"
        ip_restriction = []
    }

    app_settings = {
        APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.appins.instrumentation_key
        WEBSITE_NODE_DEFAULT_VERSION = "6.9.1"
        WEBSITE_RUN_FROM_PACKAGE = "1"
        WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
        WEBSITE_LOAD_CERTIFICATES = "7852B58B314D6ED3C5D223FA4F64A23E31DCC1B4"
        NOTIFICATIONURL = "https://dms-sponlinegateway-webapp-${local.region}-${terraform.workspace}.azurewebsites.net/api/notifications/receive"
        AUTHENTICATIONVALIDAUDIENCE = "https://dms-sponlinegateway-webapp-${local.region}-${terraform.workspace}.azurewebsites.net/"
        AUTHENTICATIONREDIRECTURI = "https://dms-sponlinegateway-webapp-${local.region}-${terraform.workspace}.azurewebsites.net/dashboard"
    }

    auth_settings {
        enabled = false
    }

    tags = local.tags
}

resource "azurerm_app_service" "gatewaywebapp_dr" {
    count       = var.DrResource.ResourceCount
    app_service_plan_id = data.azurerm_app_service_plan.shared_dr.id
    name = local.spgateway_webapp_name_dr
    location = data.azurerm_app_service_plan.shared_dr.location
    resource_group_name = azurerm_resource_group.rgdr[0].name
    https_only = "true"
    client_affinity_enabled = "true"

    identity {
        type = "SystemAssigned"
    }

    site_config {
        default_documents = ["Default.aspx"]
        dotnet_framework_version = "v4.0"
        ftps_state = "Disabled"
        always_on = "true"
        scm_type = "VSTSRM"
        ip_restriction = []
    }

    app_settings = {
        APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.appinsdr[0].instrumentation_key
        WEBSITE_NODE_DEFAULT_VERSION = "6.9.1"
        WEBSITE_RUN_FROM_PACKAGE = "1"
        WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
        WEBSITE_LOAD_CERTIFICATES = "7852B58B314D6ED3C5D223FA4F64A23E31DCC1B4"
        NOTIFICATIONURL = "https://dms-sponlinegateway-webapp-${local.region_dr}-${terraform.workspace}.azurewebsites.net/api/notifications/receive"
        AUTHENTICATIONVALIDAUDIENCE = "https://dms-sponlinegateway-webapp-${local.region}-${terraform.workspace}.azurewebsites.net/"
        AUTHENTICATIONREDIRECTURI = "https://dms-sponlinegateway-webapp-${local.region_dr}-${terraform.workspace}.azurewebsites.net/dashboard"
    }

    auth_settings {
        enabled = false
    }

    tags = local.tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "sponlinegatewayvnetintegration" {
    app_service_id = azurerm_app_service.gatewaywebapp.id
    subnet_id      = data.azurerm_subnet.appservicesubnet.id
}

resource "azurerm_app_service_virtual_network_swift_connection" "sponlinegatewayvnetintegration_dr" {
    count          = var.DrResource.ResourceCount
    app_service_id = azurerm_app_service.gatewaywebapp_dr[0].id
    subnet_id      = data.azurerm_subnet.appservicesubnet_dr[0].id
}

resource "azurerm_app_service_certificate" "gatewaywebappcert" {
  name                = "gatewaywebappcert"
  resource_group_name = azurerm_resource_group.rg.name
  location            = data.azurerm_app_service_plan.shared.location
  pfx_blob            = filebase64("Brit.pfx")
  password            = data.azurerm_key_vault_secret.sp_cert_secret.value
}

resource "azurerm_app_service_certificate" "gatewaywebappcert_dr" {
  count               = var.DrResource.ResourceCount
  name                = "gatewaywebappcert_dr"
  resource_group_name = azurerm_resource_group.rgdr[0].name
  location            = data.azurerm_app_service_plan.shared_dr.location
  pfx_blob            = filebase64("Brit.pfx")
  password            = data.azurerm_key_vault_secret.sp_cert_secret.value
}
