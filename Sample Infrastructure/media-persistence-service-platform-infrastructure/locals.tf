locals {
    resource_group_name = "${lookup(local.tags,"project")}-${lookup(local.tags,"app")}-rg-${var.azure_short_region}-${terraform.workspace}"

    tags = {
        project = "${var.project}"
        environment = "${terraform.workspace}"
        app = "${var.app}"
        contact = "${var.contact}"
        contact_details = "${var.contact_details}"
        costcentre = "${var.costcentre}"
        description = "${var.description}"
        location = "${var.azure_region}"    
        project_subcategory = "${var.subcategory}-PaaS"
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
        storage = "store",
        signalr = "signalr",
        api_management = "apimgmt",
        func_api = "funcapi"
        cosmos_db = "cosmos"
		media-persistence = "media-persist"
    }
    shared_resource_group_name = "apps-shared-rg-${var.azure_short_region}-${terraform.workspace}"

    app_service_plan_name = "apps-shared-${lookup(local.postfixes,"app_service_plan")}-${terraform.workspace}"

    storage_account_name = "medpersfuncstoruks${terraform.workspace}"

	beas_app_name = "beas-func-${terraform.workspace}"

    media_persistence_function_name = "${lookup(local.tags,"app")}-${lookup(local.postfixes,"function")}-${terraform.workspace}"
    
    app_insights_name = "${lookup(local.tags,"app")}-${lookup(local.postfixes,"app_insights")}-${terraform.workspace}"

    sql_svr_name = "${lookup(local.tags,"project")}-${lookup(local.tags,"app")}-${lookup(local.postfixes,"sql_server")}-${terraform.workspace}"

    sql_svr_db_name = "${lookup(local.tags,"app")}-${lookup(local.postfixes,"sql_database_main_instance")}-${terraform.workspace}"

    key_vault_name = "${lookup(local.postfixes,"${lookup(local.tags,"app")}")}-${lookup(local.postfixes,"key_vault")}-${terraform.workspace}"

    api_management_name = "apps-shared-${lookup(local.postfixes,"api_management")}-${terraform.workspace}"

    media_persistence_func_api_name = "${lookup(local.tags,"app")}-${lookup(local.postfixes,"func_api")}-${terraform.workspace}"

    media_persistence_api_display_name = "${lookup(local.tags,"app")}-api-${terraform.workspace}"
    
    storage_container_name = "medperscontain${var.azure_short_region}${terraform.workspace}"  
}

