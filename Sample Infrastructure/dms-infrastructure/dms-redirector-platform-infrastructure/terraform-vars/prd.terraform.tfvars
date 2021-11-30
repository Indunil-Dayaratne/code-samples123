Network = {
    Vnet = {
        Name                    = "platform-vnet01-uks-prod"
        ResourceGroup           = "platform-rg-uks-prod"
    }
    AppServiceSubnetName        = "uwac-sn-02-prod"
}

Network_Dr = {
    Vnet = {
        Name                    = "platform-vnet01-ukw-proddr"
        ResourceGroup           = "platform-rg-ukw-proddr"
    }
    AppServiceSubnetName        = "sharepoint-dms-sn-proddr"
}

KeyVault = {
    Name                    = "platform-kv-uks-prod"
    ResourceGroup           = "platform-rg-uks-prod"
}

AppServicePlan = {
    Name                    = "apps-shared-appsp-prd"
    ResourceGroup           = "apps-shared-rg-uks-prd"
}

AppServicePlan_Dr = {
    Name                    = "apps-shared-appsp-prd"
    ResourceGroup           = "apps-shared-rg-ukw-prd"
}

Resource_Dr = {
    ResourceCount           = "1"
}

cors = [
]

apim = {
    resource_group                  = "apps-shared-rg-uks-prd"
    name                            = "apps-shared-apimgmt-prd"
    base_url                        = "https://api-prd.britinsurance.com"
    location                        = "UK South"
    location_dr                     = "UK West"
    region                          = "uks"
    region_dr                       = "ukw"
    spredirector_webapp_name        = "dms-sponlineredirector-webapp-uks-prd"
    spredirector_webapp_name_dr     = "dms-sponlineredirector-webapp-ukw-prd"
    swagger_key_vault_name          = "swagger-kv-uks-prd"
    swagger_resource_group_name     = "uwac-swagger-rg-uks-prd"
}