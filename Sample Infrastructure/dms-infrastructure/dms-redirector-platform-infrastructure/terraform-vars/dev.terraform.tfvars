Network = {
    Vnet = {
        Name                    = "platform-vnet01-uks-dev"
        ResourceGroup           = "platform-rg-uks-dev"
    }
    AppServiceSubnetName        = "uwac-sn-02-dev"    
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
    Name                    = "apps-shared-appsp-dev"
    ResourceGroup           = "apps-shared-rg-uks-dev"
}

AppServicePlan_Dr = {
    Name                    = "apps-shared-appsp-tst"
    ResourceGroup           = "apps-shared-rg-ukw-tst"
}

Resource_Dr = {
    ResourceCount           = "0"
}

cors = [
]

apim = {
    resource_group                  = "apps-shared-rg-uks-tst"
    name                            = "apps-shared-apimgmt-tst"
    base_url                        = "https://api-dev.britinsurance.com"
    location                        = "UK South"
    location_dr                     = "UK South"
    region                          = "uks"
    region_dr                       = "uks"
    spredirector_webapp_name       = "dms-sponlineredirector-webapp-uks-dev"
    spredirector_webapp_name_dr    = "dms-sponlineredirector-webapp-uks-dev"
    swagger_key_vault_name          = "swagger-kv-uks-dev"
    swagger_resource_group_name     = "uwac-swagger-rg-uks-dev"
}