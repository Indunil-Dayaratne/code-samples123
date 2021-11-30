Network = {
    Vnet = {
        Name                    = "platform-vnet01-uks-uat"
        ResourceGroup           = "platform-rg-uks-uat"
    }
    AppServiceSubnetName        = "uwac-sn-02-uat"
}

Network_Dr = {
    Vnet = {
        Name                    = "platform-vnet01-ukw-nonprod"
        ResourceGroup           = "platform-rg-ukw-nonprod"
    }
    AppServiceSubnetName        = "platform-sn-ukw-nonprod"
}

KeyVault = {
    Name                    = "platform-kv-uks-nonprod"
    ResourceGroup           = "platform-rg-uks-nonprod"
}

AppServicePlan = {
    Name                    = "apps-shared-appsp-uat"
    ResourceGroup           = "apps-shared-rg-uks-uat"
}

AppServicePlan_Dr = {
    Name                    = "apps-shared-appsp-tst"
    ResourceGroup           = "apps-shared-rg-ukw-tst"
}

Resource_Dr = {
    ResourceCount           = "1"
}

cors = [
]

apim = {
    resource_group                  = "apps-shared-rg-uks-tst"
    name                            = "apps-shared-apimgmt-tst"
    base_url                        = "https://api-test.britinsurance.com"
    location                        = "UK South"
    location_dr                     = "UK West"
    region                          = "uks"
    region_dr                       = "ukw"
    spredirector_webapp_name        = "dms-sponlineredirector-webapp-uks-uat"
    spredirector_webapp_name_dr     = "dms-sponlineredirector-webapp-ukw-uat"
    swagger_key_vault_name          = "swagger-kv-uks-uat"
    swagger_resource_group_name     = "uwac-swagger-rg-uks-uat"
}