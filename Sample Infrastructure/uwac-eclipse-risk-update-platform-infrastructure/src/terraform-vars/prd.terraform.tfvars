azure_short_region      = "uks"
azure_region            = "UK South"
azure_short_region_dr   = "ukw"
azure_region_dr         = "UK West"

apim = {
    resource_group      = "apps-shared-rg-uks-prd"
    name                = "apps-shared-apimgmt-prd"
    base_url            = "https://api-prd.britinsurance.com"
}

esb = {
    resource_group      = "rg-prd-esb-uks-01"
    storage_account     = "prdesbstore"
    service_bus         = "prd-esb-uks-svcbus"
}

shared = {
    app_service_plan    = "apps-shared-appsp-prd"
    resource_group      = "apps-shared-rg-uks-prd"
}

shared_dr = {
    app_service_plan    = "apps-shared-appsp-prd"
    resource_group      = "apps-shared-rg-ukw-prd"
}

common_shared = {
    storage_account     = "britstoruksprod"
    resource_group      = "apps-common-shared-services-rg-uks-prod"
}

common_shared_dr = {
    storage_account     = "britstorukwprod"
    resource_group      = "apps-common-shared-services-rg-ukw-prod"
}

cors = [
    "https://opus/"
]

reply_urls = [
    "https://opus",
    "https://opus/Home/LoginRedirect"
]

subnet = {
    name                    = "uwac-sn-02-prod"
    resource_group          = "platform-rg-uks-prod"
    vnet_name               = "platform-vnet01-uks-prod"
}

subnet_dr = {
    name                    = "asr-01-nic-uks-proddr"
    resource_group          = "platform-rg-ukw-proddr"
    vnet_name               = "platform-vnet01-ukw-proddr"
}

eclipse_base_url            ="http://briuwbaeqprda.sbsbritsso.local/Sequel.UW.WS.EclipsePolicyWcfService/PolicyService.svc"
service_account_name        ="wren\\svc_uw_prod"