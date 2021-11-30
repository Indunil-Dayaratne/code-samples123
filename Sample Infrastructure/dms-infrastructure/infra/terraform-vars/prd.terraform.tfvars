Network = {
    RouteTable = {
        Name                    = "platform-rt-uks-prod"
        ResourceGroup           = "platform-rg-uks-prod"
    }
    Vnet = {
        Name                    = "platform-vnet01-uks-prod"
        ResourceGroup           = "platform-rg-uks-prod"
    }
    Nsg = {
        Name                    = "default-apps-sn-nsg"
        ResourceGroup           = "apps-shared-rg-uks-prd"
    }

    AppServiceSubnetName        = "dms-sn-01-prod"
    SubnetCidr                  = "10.8.190.0/24"
}

Network_Dr = {
    Vnet = {
        Name                    = "platform-vnet01-ukw-proddr"
        ResourceGroup           = "platform-rg-ukw-proddr"
    }
    
    AppServiceSubnetName        = "sharepoint-dms-sn-proddr"
}

SqlVm = {
    Size = "Standard_DS12_v2"
    Sku = "enterprise"
}

KeyVault = {
    Name                    = "platform-kv-uks-prod"
    ResourceGroup           = "platform-rg-uks-prod"
}

AppServicePlan = {
    Name                    = "apps-shared-dms-appsp-prd"
    ResourceGroup           = "apps-shared-rg-uks-prd"
}

AppServicePlanDr = {
    Name                    = "apps-shared-appsp-prd"
    ResourceGroup           = "apps-shared-rg-ukw-prd"
}

ReplyUrls = [
	"https://dms-sponlinegateway-webapp-uks-prd.azurewebsites.net/.auth/login/aad/callback",
    "https://dms-sponlinegateway-webapp-ukw-prd.azurewebsites.net/.auth/login/aad/callback",
    "https://api-prd.britinsurance.com/dms-sponline-prd/.auth/login/aad/callback",
	"https://opus/Home/LoginRedirect",
	"https://dms-sponlinegateway-webapp-uks-prd.azurewebsites.net/dashboard",
    "https://dms-sponlinegateway-webapp-ukw-prd.azurewebsites.net/dashboard",
    "https://api-prd.britinsurance.com/dms-sponline-prd/dashboard"
]

DrResource = {
    ResourceCount           = 1
}

cors = [
    "https://opus"
]

apim = {
    resource_group              = "apps-shared-rg-uks-prd"
    name                        = "apps-shared-apimgmt-prd"
    base_url                    = "https://api-prd.britinsurance.com"
    location                    = "UK South"
    location_dr                 = "UK West"
    region                      = "uks"
    region_dr                   = "ukw"
    spgateway_webapp_name       = "dms-sponlinegateway-webapp-uks-prd"
    spgateway_webapp_name_dr    = "dms-sponlinegateway-webapp-ukw-prd"
    swagger_key_vault_name      = "swagger-kv-uks-prd"
    swagger_resource_group_name = "uwac-swagger-rg-uks-prd"
}