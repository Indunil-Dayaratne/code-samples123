Network = {
    RouteTable = {
        Name                    = "platform-rt-uks-uat"
        ResourceGroup           = "platform-rg-uks-uat"
    }
    Vnet = {
        Name                    = "platform-vnet01-uks-uat"
        ResourceGroup           = "platform-rg-uks-uat"
    }
    Nsg = {
        Name                    = "default-apps-sn-nsg"
        ResourceGroup           = "apps-shared-rg-uks-tst"
    }
    
    AppServiceSubnetName        = "uwac-sn-02-uat"
    SubnetCidr                  = "10.4.90.0/24"
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
    Name                    = "apps-shared-appsp-uat"
    ResourceGroup           = "apps-shared-rg-uks-uat"
}

AppServicePlanDr = {
    Name                    = "apps-shared-appsp-tst"
    ResourceGroup           = "apps-shared-rg-ukw-tst"
}

ReplyUrls = [
	"https://dms-sponlinegateway-webapp-uks-uat.azurewebsites.net/.auth/login/aad/callback",
    "https://dms-sponlinegateway-webapp-ukw-uat.azurewebsites.net/.auth/login/aad/callback",
    "https://api-test.britinsurance.com/dms-sponline-uat/.auth/login/aad/callback",
	"https://opus-uat/Home/LoginRedirect",
	"https://opus-test/Home/LoginRedirect",
	"https://opus-staging/Home/LoginRedirect",
	"https://dms-sponlinegateway-webapp-uks-uat.azurewebsites.net/dashboard",
    "https://dms-sponlinegateway-webapp-ukw-uat.azurewebsites.net/dashboard",
    "https://api-test.britinsurance.com/dms-sponline-uat/dashboard"
]

DrResource = {
    ResourceCount           = 1
}

cors = [
    "https://opus-uat",
    "https://opus-test",
    "https://opus-staging/"
]

apim = {
    resource_group              = "apps-shared-rg-uks-tst"
    name                        = "apps-shared-apimgmt-tst"
    base_url                    = "https://api-test.britinsurance.com"
    location                    = "UK South"
    location_dr                 = "UK West"
    region                      = "uks"
    region_dr                   = "ukw"
    spgateway_webapp_name       = "dms-sponlinegateway-webapp-uks-uat"
    spgateway_webapp_name_dr    = "dms-sponlinegateway-webapp-ukw-uat"
    swagger_key_vault_name      = "swagger-kv-uks-uat"
    swagger_resource_group_name = "uwac-swagger-rg-uks-uat"
}