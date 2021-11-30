resource "azuread_application" "gateway_app_registration" {
    name = "sharepoint-dms-sponlinegateway-${terraform.workspace}"
    homepage                   = "https://${local.spgateway_webapp_name}.azurewebsites.net"
    identifier_uris            = [
        "https://${local.spgateway_webapp_name}.azurewebsites.net"
       ]
    reply_urls                 = var.ReplyUrls
    available_to_other_tenants = false
    oauth2_allow_implicit_flow = true
    
    owners = ["dfc264e6-c20c-4087-b70a-51ac0c70ca6a", "9c052402-5ce5-4243-abd7-37b833d98a56"] // Indunil D, Yogesh N
    
    //required resource access relates to API permissions section of sharepoint-dms-web-[env] app service configuration
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

resource "random_password" "serviceapp_secret" {
    length  = 33
    special = true
}

resource "azuread_application_password" "serviceapp_secret" {
    description           = "AcceptanceTestExecution"
    application_object_id = azuread_application.gateway_app_registration.id
    value                 = random_password.serviceapp_secret.result
    end_date              = "2099-01-01T01:00:00Z"
}