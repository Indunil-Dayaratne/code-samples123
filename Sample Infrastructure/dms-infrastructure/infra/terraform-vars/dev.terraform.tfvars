Network = {
    RouteTable = {
        Name                    = "platform-rt-uks-dev"
        ResourceGroup           = "platform-rg-uks-dev"
    }
    Vnet = {
        Name                    = "platform-vnet01-uks-dev"
        ResourceGroup           = "platform-rg-uks-dev"
    }
    Nsg = {
        Name                    = "default-apps-sn-nsg"
        ResourceGroup           = "apps-shared-rg-uks-tst"
    }
    
    AppServiceSubnetName        = "uwac-sn-02-dev"
    SubnetCidr                  = "10.0.90.0/24"
}

Network_Dr = {
    Vnet = {
        Name                    = "platform-vnet01-ukw-nonprod"
        ResourceGroup           = "platform-rg-ukw-nonprod"
    }
    
    AppServiceSubnetName        = "platform-sn-ukw-nonprod"
}

SqlVm = {
    Size = "Standard_DS12_v2"
    Sku = "sqldev"
}

KeyVault = {
    Name                    = "platform-kv-uks-nonprod"
    ResourceGroup           = "platform-rg-uks-nonprod"
}

AppServicePlan = {
    Name                    = "apps-shared-appsp-dev"
    ResourceGroup           = "apps-shared-rg-uks-dev"
}

AppServicePlanDr = {
    Name                    = "apps-shared-appsp-tst"
    ResourceGroup           = "apps-shared-rg-ukw-tst"
}

ReplyUrls = [
	"https://dms-sponlinegateway-webapp-uks-dev.azurewebsites.net/.auth/login/aad/callback",
    "https://api-dev.britinsurance.com/dms-sponline-dev/.auth/login/aad/callback",
	"https://opus-dev/Home/LoginRedirect",
	"https://localhost/Home/LoginRedirect",
	"https://dms-sponlinegateway-webapp-uks-dev.azurewebsites.net/dashboard",
    "https://api-dev.britinsurance.com/dms-sponline-dev/dashboard",
	"https://localhost:44341/dashboard"
]

DrResource = {
    ResourceCount           = 0
}

cors = [
    "https://opus-dev",
    "https://localhost"
]

apim = {
    resource_group              = "apps-shared-rg-uks-tst"
    name                        = "apps-shared-apimgmt-tst"
    base_url                    = "https://api-dev.britinsurance.com"
    location                    = "UK South"
    location_dr                 = "UK South"
    region                      = "uks"
    region_dr                   = "uks"
    spgateway_webapp_name       = "dms-sponlinegateway-webapp-uks-dev"
    spgateway_webapp_name_dr    = "dms-sponlinegateway-webapp-uks-dev"
    swagger_key_vault_name      = "swagger-kv-uks-dev"
    swagger_resource_group_name = "uwac-swagger-rg-uks-dev"
}