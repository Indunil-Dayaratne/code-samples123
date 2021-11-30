locals {

    tags = {
        environment = terraform.workspace
        app = "brit-architecture"
        project = "common"
        app_short_name = "architecture"
        contact = "Thomas Mathew"
        contact_details = "ext 100712"
        costcentre = "X123"
        description = "Resources for Brit Architecture Team"
        location = var.primary.azure_region   
        project_subcategory = "PaaS"
        business_name = "Architecture"
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

    resource_group_name = var.primary.resource_group
    sql_server_name =  "${lookup(local.tags, "app")}-${lookup(local.postfixes,"sql_server")}-${var.primary.azure_short_region}-${lookup(local.tags,"environment")}"
    ad_group_name = "Solution Architects"
    sql_svr_db_name = "EnterpriseArchitect"
}