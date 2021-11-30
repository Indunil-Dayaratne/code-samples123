locals {

    tags = {
        project = "apps"
        environment = terraform.workspace
        app = "common-shared-services"
        app_short_name = "common"
        contact = "Ahmet Demir"
        contact_details = "ext 10129"
        costcentre = "N37"
        description = "Shared resources like CosmosDB"
        location = var.primary.azure_region   
        project_subcategory = "PaaS"
        business_name = "Opus"
    }

    tags_dr = {
        project = "apps"
        environment = terraform.workspace
        app = "common-shared-services"
        app_short_name = "common"
        contact = "Ahmet Demir"
        contact_details = "ext 10129"
        costcentre = "N37"
        description = "Shared resources like CosmosDB"
        location = var.azure_region_dr 
        project_subcategory = "PaaS"
        business_name = "Opus"
    }

    postfixes = {
        app_insights = "appins"
        sql_server = "sqlsvr"
        sql_database_main_instance = "sqldbmi"
        web_app = "webapp"
        app_service_plan = "appsp"
        function ="func"
        cognitive_vision = "cogvis"
        key_vault = "kv"
        storage = "store"
        signalr = "signalr"
        api_management = "apimgmt"
        func_api = "funcapi"
        cosmos_db = "cosmos"
        service_bus = "svcbus"        
    }

    resource_group_name = "${lookup(local.tags,"project")}-${lookup(local.tags,"app")}-rg"
    storage_account_name =  "britstor"
}