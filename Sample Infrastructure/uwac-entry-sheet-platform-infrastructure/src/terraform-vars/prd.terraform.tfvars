azure_short_region                  = "uks"
azure_region                        = "UK South"
azure_appins_region                 = "UK South"
    
azure_short_region_dr               = "ukw"
azure_region_dr                     = "UK West"
dr_resource_count                   = 1

beas_base_url                       = "https://beas-func-prd.azurewebsites.net/api"
eclipse_riskapi_base_url            = "https://eclipse-risk-api-func-uks-prd.azurewebsites.net"
eclipse_risk_validation_api_base_url = "https://eclipse-risk-validator-func-uks-prd.azurewebsites.net"
pbqa_api_base_url                   = "https://pbqa-func-uks-prd.azurewebsites.net/api"
britcache_api_base_url              = "https://britcache-proxy-api-func-uks-prd.azurewebsites.net/"
ignis_api_url                       = "http://localhost:6565/api/excel"
ignis_api_environmentName           = "Ignis"
cosmos_database_endpoint_url        = "https://apps-common-cosmos-prod.documents.azure.com:443/"

shared = {
    app_service                     = "apps-shared-appsp-prd"
    resource_group                  = "apps-shared-rg-uks-prd"
}

shared_dr = {
    app_service                     = "apps-shared-appsp-prd"
    resource_group                  = "apps-shared-rg-ukw-prd"
}

common_shared = {
    storage_account                 = "britstoruksprod"
    resource_group                  = "apps-common-shared-services-rg-uks-prod"
}

common_shared_dr = {
    storage_account                 = "britstorukwprod"
    resource_group                  = "apps-common-shared-services-rg-ukw-prod"
}

cosmos = {
    account_name                    = "apps-common-cosmos-prod"
    db_name                         = "shared"
    resource_group                  = "apps-common-shared-services-rg-uks-prod"
}

cors = [
    "https://opus"
]

reply_urls = [
    "https://opus",
    "https://opus/Home/LoginRedirect"
]
