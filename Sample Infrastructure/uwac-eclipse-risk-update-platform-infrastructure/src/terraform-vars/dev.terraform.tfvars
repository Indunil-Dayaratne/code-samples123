azure_short_region      = "uks"
azure_region            = "UK South"
azure_short_region_dr   = "ukw"
azure_region_dr         = "UK West"

apim = {
    resource_group      = "apps-shared-rg-uks-tst"
    name                = "apps-shared-apimgmt-tst"
    base_url            = "https://api-test.britinsurance.com"
}

esb = {
    resource_group      = "rg-dev-esb-uks-01"
    storage_account     = "devesbstore"
    service_bus         = "dev-esb-uks-svcbus"
}

shared = {
    app_service_plan    = "apps-shared-appsp-dev"
    resource_group      = "apps-shared-rg-uks-dev"
}

shared_dr = {
    app_service_plan    = "apps-shared-appsp-tst"
    resource_group      = "apps-shared-rg-ukw-tst"
}

common_shared = {
    storage_account     = "britstoruksnonprod"
    resource_group      = "apps-common-shared-services-rg-uks-nonprod"
}

common_shared_dr = {
    storage_account     = "britstorukwnonprod"
    resource_group      = "apps-common-shared-services-rg-ukw-nonprod"
}

cors = [
    "https://opus-dev/",
    "https://localhost"
]

reply_urls = [
    "https://localhost/Home/LoginRedirect",
    "https://localhost",
    "https://opus-dev",
    "https://opus-dev/Home/LoginRedirect",
    "https://www.getpostman.com/oauth2/callback"
]

subnet = {
    name                    = "uwac-sn-02-dev"
    resource_group          = "platform-rg-uks-dev"
    vnet_name               = "platform-vnet01-uks-dev"
}

subnet_dr = {
    name                    = "platform-sn-ukw-nonprod"
    resource_group          = "platform-rg-ukw-nonprod"
    vnet_name               = "platform-vnet01-ukw-nonprod"
}
 
eclipse_base_url            ="http://briuwuaeqsbxa1.sbsbritsso.local/Sequel.UW.WS.EclipsePolicyWcfService/PolicyService.svc"
service_account_name        ="wren\\svc_uw_dev"