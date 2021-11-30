data "azurerm_app_service_plan" "shared" {
    name = "${var.app_service_plan_name}"
    resource_group_name = "${var.app_service_plan_resource_group_name}"
}

locals {
    webapp_name = "aspire-webapp-${terraform.workspace}"
}

resource "azuread_application" "aspire_app_registration" {
    name = "aspire-webapp-${terraform.workspace}"
    homepage                   = "https://${local.webapp_name}.azurewebsites.net"
    identifier_uris            = ["https://${local.webapp_name}.azurewebsites.net"]
    reply_urls                 = ["https://${local.webapp_name}.azurewebsites.net/.auth/login/aad/callback"]
    available_to_other_tenants = false
    oauth2_allow_implicit_flow = true

    //required resource access relates to API permissions section of aspire-web-[env] app service configuration
    //Permissions granted are read only for Azure Active Directory Graph and Microsoft Graph
    //https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/CallAnAPI/appId/4c7021cd-a974-4053-b1bb-08821f9fcc4a/isMSAApp/
    required_resource_access {
        resource_app_id = "00000002-0000-0000-c000-000000000000"
        resource_access {
            id = "a42657d6-7f20-40e3-b6f0-cee03008a62a"
            type = "Scope"
        }
        resource_access {
            id = "5778995a-e1bf-45b8-affa-663a9f3f4d04"
            type = "Scope"
        }
        resource_access {
            id = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
            type = "Scope"
        }
    }
    
    required_resource_access {
        resource_app_id = "00000003-0000-0000-c000-000000000000"
        resource_access {
            id = "06da0dbc-49e2-44d2-8312-53f166ab848a"
            type = "Scope"
        }
        resource_access {
            id = "5f8c59db-677d-491f-a6b8-5f174b11ec1d"
            type = "Scope"
        }
        resource_access {
            id = "a154be20-db9c-4678-8ab7-66f6cc099a59"
            type = "Scope"
        }
        resource_access {
            id = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
            type = "Role"
        }
        resource_access {
            id = "5b567255-7703-4780-807c-7be8301ae99b"
            type = "Role"
        }
        resource_access {
            id = "df021288-bdef-4463-88db-98f22de89214"
            type = "Role"
        }
    }
}

resource "azurerm_app_service" "aspirewebapp" {
    app_service_plan_id = "${data.azurerm_app_service_plan.shared.id}"
    name = "${local.webapp_name}"
    location = "${data.azurerm_app_service_plan.shared.location}"
    resource_group_name = "${azurerm_resource_group.aspire_rg.name}"
    
    https_only = "true"
    client_affinity_enabled = "true" //Aspire uses session for various user settings
    
    identity {
        type = "SystemAssigned"
    }
    
    site_config {
        default_documents = ["Default.aspx"]
        dotnet_framework_version = "v4.0"
        always_on = "true"
        scm_type = "VSTSRM"
    }
    
    app_settings {
        "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.current.instrumentation_key}"
        "WEBSITE_NODE_DEFAULT_VERSION" = "6.9.1"
        "WEBSITE_RUN_FROM_PACKAGE" = "0"
    }
    
    auth_settings {
        enabled = true
        issuer = "https://sts.windows.net/8cee18df-5e2a-4664-8d07-0566ffea6dcd"
        default_provider = "AzureActiveDirectory"
        unauthenticated_client_action = "RedirectToLoginPage"
        
        active_directory {
            client_id = "${azuread_application.aspire_app_registration.application_id}"
            allowed_audiences = ["https://${local.webapp_name}.azurewebsites.net/.auth/login/aad/callback", "https://${local.webapp_name}.azurewebsites.net"]
        }
    }

    tags = "${local.tags}"
}