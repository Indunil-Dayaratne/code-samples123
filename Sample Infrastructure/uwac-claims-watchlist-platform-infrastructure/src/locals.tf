locals {

    tags = {
        project = "uwac"
        environment = terraform.workspace
        app = "claimswl"
        contact = "Indunil Dayaratne"
        contact_details = "indunil.dayaratne@britinsurance.com"
        costcentre = "G31"
        description = "Eclipse claims watch list service"
        location = var.azure_region   
        project_subcategory = "Opus-PaaS"
        business_name = "Opus"
    }

    tags_dr = {
        project = "uwac"
        environment = terraform.workspace
        app = "claimswl"
        contact = "Indunil Dayaratne"
        contact_details = "indunil.dayaratne@britinsurance.com"
        costcentre = "N37"
        description ="Eclipse claims watch list service"
        location = var.azure_region_dr 
        project_subcategory = "Opus-PaaS"
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
    api_func_name =  "${lookup(local.tags,"app")}-api-${lookup(local.postfixes,"function")}"
    key_vault_name = "${lookup(local.tags,"app")}-${lookup(local.postfixes,"key_vault")}" 
    func_aad_name = "${lookup(local.tags,"app")}-${lookup(local.postfixes,"function")}"
    web_app_name = "${lookup(local.tags,"app")}-${lookup(local.postfixes,"web_app")}"
    web_aad_name = "${lookup(local.tags,"app")}-${lookup(local.postfixes,"web_app")}"
    app_insights_name = "${lookup(local.tags,"app")}-${lookup(local.postfixes,"app_insights")}"
    app_service_plan = "claimswl-appsp"
}