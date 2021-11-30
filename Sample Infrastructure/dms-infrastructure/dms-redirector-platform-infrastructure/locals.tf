locals {
    tags = {
        project             = "Sharepoint DMS"
        environment         = terraform.workspace
        app                 = "dms-redirector"
        app_group           = "sharepoint-dms"
        business_name       = "SharePoint"
        contact             = "Paul Mulholland"
        contact_details     = "paul.mulholland@britinsurance.com"
        technical_contact   = "Thomas Mathew"
        costcentre          = "N37"
        description         = "Services managing ingestion into Sharepoint from other Brit Systems"
        location            = "UK South"
        location_dr         = "UK West"
        terraformed         = "yes"
        repo                = "https://dev.azure.com/britgroupservices/Apps/_git/brit-dms-source"
    }
    region = "uks"
    region_dr = "ukw"
    spredirector_webapp_name = "dms-sponlineredirector-webapp-${local.region}-${terraform.workspace}"
    spredirector_webapp_name_dr = "dms-sponlineredirector-webapp-${local.region_dr}-${terraform.workspace}"
}