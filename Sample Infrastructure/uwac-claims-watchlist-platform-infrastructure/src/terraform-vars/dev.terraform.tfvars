azure_short_region = "uks"
azure_region = "UK South"
azure_appins_region = "UK South"

azure_short_region_dr = "ukw"
azure_region_dr = "UK West"
dr_resource_count=0
beas_base_url = "https://beas-func-dev.azurewebsites.net/api"
britcache_api_base_url = "https://britcache-proxy-api-func-uks-dev.azurewebsites.net/"
cosmos_database_endpoint_url = "https://apps-common-cosmos-nonprod.documents.azure.com:443/"

shared = {
    app_service = "apps-shared-appsp-dev"
    resource_group = "apps-shared-rg-uks-dev"
}

shared_dr = {
    app_service = "apps-shared-appsp-tst"
    resource_group = "apps-shared-rg-ukw-tst"
}

cosmos = {
    account_name = "apps-common-cosmos-nonprod"
    db_name = "shared"
    resource_group = "apps-common-shared-services-rg-uks-nonprod"
}

common_shared = {
    storage_account = "britstoruksnonprod"
    resource_group = "apps-common-shared-services-rg-uks-nonprod"
}

common_shared_dr = {
    storage_account = "britstorukwnonprod"
    resource_group = "apps-common-shared-services-rg-ukw-nonprod"
}

cors = [
    "https://opus-dev",
    "https://localhost"
]

reply_urls = [
    "https://www.getpostman.com/oauth2/callback",
    "https://localhost/Home/LoginRedirect",
    "https://localhost",
    "https://opus-dev",
    "https://opus-dev/Home/LoginRedirect"
]

user_preferences = {
    preference_key = "CWL_Selected_Group_Classes"
    preference_key_id = 3097
    grid_preference_key = "CWL_OpenItems_Grid_Views"
    grid_preference_key_id = 3098
}