locals {
    tags = {
        project         = "Sharepoint DMS"
        environment     = terraform.workspace
        app             = "sharepoint-dms"
        business_name   = "SharePoint"
        contact         = "Stephen Aggett"
        contact_details = "stephen.aggett@britinsurance.com"
        costcentre      = "N37"
        description     = "Services managing ingestion into Sharepoint from other Brit Systems"
        location        = "UK South"
        location_dr     = "UK West"
        terraformed     = "yes"
        repo            = "https://dev.azure.com/britgroupservices/Apps/_git/brit-dms-source"
    }
    region = "uks"
    region_dr = "ukw"
    spgateway_webapp_name = "dms-sponlinegateway-webapp-${local.region}-${terraform.workspace}"
    spgateway_webapp_name_dr = "dms-sponlinegateway-webapp-${local.region_dr}-${terraform.workspace}"
    swagger_key_vault_name = "swagger-kv-${local.region}-${terraform.workspace}"
    swagger_resource_group_name = "uwac-swagger-rg-${local.region}-${terraform.workspace}"
}