azure_short_region                  = "uks"
azure_region                        = "UK South"
azure_appins_region                 = "UK South"
    
azure_short_region_dr               = "ukw"
azure_region_dr                     = "UK West"
dr_resource_count                   = 1

beas_base_url                       = "https://beas-func-uat.azurewebsites.net/api"
britcache_api_base_url              = "https://britcache-proxy-api-func-uks-uat.azurewebsites.net/"
cosmos_database_endpoint_url        = "https://apps-common-cosmos-nonprod.documents.azure.com:443/"

shared = {
    app_service                     = "apps-shared-appsp-uat"
    resource_group                  = "apps-shared-rg-uks-uat"
}

shared_dr = {
    app_service                     = "apps-shared-appsp-tst"
    resource_group                  = "apps-shared-rg-ukw-tst"
}

common_shared = {
    storage_account                 = "britstoruksnonprod"
    resource_group                  = "apps-common-shared-services-rg-uks-nonprod"
}

common_shared_dr = {
    storage_account                 = "britstorukwnonprod"
    resource_group                  = "apps-common-shared-services-rg-ukw-nonprod"
}

cosmos = {
    account_name                    = "apps-common-cosmos-nonprod"
    db_name                         = "shared"
    resource_group                  = "apps-common-shared-services-rg-uks-nonprod"
}

cors = [
    "https://opus-staging"
]

reply_urls = [
    "https://opus-staging",
    "https://opus-staging/Home/LoginRedirect"
]
