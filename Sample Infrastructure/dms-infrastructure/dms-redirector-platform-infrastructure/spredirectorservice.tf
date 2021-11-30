data "azurerm_app_service_plan" "shared" {
    name = var.AppServicePlan.Name
    resource_group_name = var.AppServicePlan.ResourceGroup
}

data "azurerm_app_service_plan" "shared_dr" {
    name = var.AppServicePlan_Dr.Name
    resource_group_name = var.AppServicePlan_Dr.ResourceGroup
}

resource "azurerm_app_service" "redirectorwebapp" {
    app_service_plan_id = data.azurerm_app_service_plan.shared.id
    name = local.spredirector_webapp_name
    location = data.azurerm_app_service_plan.shared.location
    resource_group_name = data.azurerm_resource_group.rg.name
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
        ip_restriction = [ {name = "BritAzureVDI", ip_address = "194.0.238.7/32", action = "Allow", priority = "100"},
                           {name = "BritCorp", ip_address = "84.207.239.144/28", action = "Allow", priority = "200"},
                           {name = "ZScaler", ip_address = "165.225.80.0/24", action = "Allow", priority = "300"},
                           {name = "ZScaler2", ip_address = "147.161.166.0/23", action = "Allow", priority = "301"},
                           {name = "ZScalerUS", ip_address = "168.62.109.126/32", action = "Allow", priority = "302"},
                           {name = "ZScalerFailover", ip_address = "165.225.88.0/24", action = "Allow", priority = "400"},
                           {name = "SequelEclipseUat", ip_address = "52.213.31.200/32", action = "Allow", priority = "500"},
                           {name = "SequelEclipseUat2", ip_address = "52.214.190.164/32", action = "Allow", priority = "505"},
                           {name = "SequelEclipseShared", ip_address = "34.251.46.146/32", action = "Allow", priority = "510"},
                           {name = "SequelEclipseShared2", ip_address = "34.242.12.62/32", action = "Allow", priority = "515"},
                           {name = "SequelEclipseProd", ip_address = "34.253.0.91/32", action = "Allow", priority = "520"},
                           {name = "SequelEclipseProd2", ip_address = "34.249.92.25/32", action = "Allow", priority = "525"},
                           {name = "SequelEclipseDR", ip_address = "35.156.73.17/32", action = "Allow", priority = "530"},
                           {name = "SequelEclipseDR2", ip_address = "18.196.155.174/32", action = "Allow", priority = "535"},
                           {name = "AzureFirewallUKSouth", ip_address = "40.81.145.128/32", action = "Allow", priority = "600"},
                           {name = "AzureFirewallUKWest", ip_address = "40.81.125.132/32", action = "Allow", priority = "601"},
                           {name = "APIM-Test", service_tag = "ApiManagement.UkSouth", action = "Allow", priority = "700"},
                           {name = "AzureFrontDoorFrontend", service_tag = "AzureFrontDoor.Frontend", action = "Allow", priority = "701"},
                           {name = "AzureFrontDoorBackend", service_tag = "AzureFrontDoor.Backend", action = "Allow", priority = "702"},
                           {name = "AzureFrontDoorFirstParty", service_tag = "AzureFrontDoor.FirstParty", action = "Allow", priority = "703"}
                         ]
        scm_use_main_ip_restriction = "true"
    }

    app_settings = {
        APPINSIGHTS_INSTRUMENTATIONKEY = data.azurerm_application_insights.appins.instrumentation_key
        WEBSITE_NODE_DEFAULT_VERSION = "6.9.1"
        WEBSITE_RUN_FROM_PACKAGE = "1"
        WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
        WEBSITE_LOAD_CERTIFICATES = "7852B58B314D6ED3C5D223FA4F64A23E31DCC1B4"
    }

    tags = local.tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "sponlineredirectorvnetintegration" {
    app_service_id = azurerm_app_service.redirectorwebapp.id
    subnet_id      = data.azurerm_subnet.appservicesubnet.id
}

resource "azurerm_app_service" "redirectorwebapp_dr" {
    count  = "${var.Resource_Dr.ResourceCount}"
    app_service_plan_id = data.azurerm_app_service_plan.shared_dr.id
    name = local.spredirector_webapp_name_dr
    location = data.azurerm_app_service_plan.shared_dr.location
    resource_group_name = data.azurerm_resource_group.rg_dr[0].name
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
        ip_restriction = [ {name = "BritAzureVDI", ip_address = "194.0.238.7/32", action = "Allow", priority = "100"},
                           {name = "BritCorp", ip_address = "84.207.239.144/28", action = "Allow", priority = "200"},
                           {name = "ZScaler", ip_address = "165.225.80.0/24", action = "Allow", priority = "300"},
                           {name = "ZScaler2", ip_address = "147.161.166.0/23", action = "Allow", priority = "301"},
                           {name = "ZScalerUS", ip_address = "168.62.109.126/32", action = "Allow", priority = "302"},
                           {name = "ZScalerFailover", ip_address = "165.225.88.0/24", action = "Allow", priority = "400"},
                           {name = "SequelEclipseUat", ip_address = "52.213.31.200/32", action = "Allow", priority = "500"},
                           {name = "SequelEclipseUat2", ip_address = "52.214.190.164/32", action = "Allow", priority = "505"},
                           {name = "SequelEclipseShared", ip_address = "34.251.46.146/32", action = "Allow", priority = "510"},
                           {name = "SequelEclipseShared2", ip_address = "34.242.12.62/32", action = "Allow", priority = "515"},
                           {name = "SequelEclipseProd", ip_address = "34.253.0.91/32", action = "Allow", priority = "520"},
                           {name = "SequelEclipseProd2", ip_address = "34.249.92.25/32", action = "Allow", priority = "525"},
                           {name = "SequelEclipseDR", ip_address = "35.156.73.17/32", action = "Allow", priority = "530"},
                           {name = "SequelEclipseDR2", ip_address = "18.196.155.174/32", action = "Allow", priority = "535"},
                           {name = "AzureFirewallUKSouth", ip_address = "40.81.145.128/32", action = "Allow", priority = "600"},
                           {name = "AzureFirewallUKWest", ip_address = "40.81.125.132/32", action = "Allow", priority = "601"},
                           {name = "APIM-Test", service_tag = "ApiManagement.UkSouth", action = "Allow", priority = "700"},
                           {name = "AzureFrontDoorFrontend", service_tag = "AzureFrontDoor.Frontend", action = "Allow", priority = "701"},
                           {name = "AzureFrontDoorBackend", service_tag = "AzureFrontDoor.Backend", action = "Allow", priority = "702"},
                           {name = "AzureFrontDoorFirstParty", service_tag = "AzureFrontDoor.FirstParty", action = "Allow", priority = "703"}
                         ]
        scm_use_main_ip_restriction = "true"
    }

    app_settings = {
        APPINSIGHTS_INSTRUMENTATIONKEY = data.azurerm_application_insights.appins_dr[0].instrumentation_key
        WEBSITE_NODE_DEFAULT_VERSION = "6.9.1"
        WEBSITE_RUN_FROM_PACKAGE = "1"
        WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
        WEBSITE_LOAD_CERTIFICATES = "7852B58B314D6ED3C5D223FA4F64A23E31DCC1B4"
    }

    tags = local.tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "sponlineredirectorvnetintegration_dr" {
    count          = "${var.Resource_Dr.ResourceCount}"
    app_service_id = azurerm_app_service.redirectorwebapp_dr[0].id
    subnet_id      = data.azurerm_subnet.appservicesubnet_dr.id
    depends_on     =[azurerm_app_service.redirectorwebapp_dr[0]]
}