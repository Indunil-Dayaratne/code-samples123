locals {
    resource_group_name = "${lookup(local.tags,"project")}-${lookup(local.tags,"app_shortname")}-rg-${var.azure_short_region}-${terraform.workspace}"

    tags = {
        project = "${var.project}"
        environment = "${terraform.workspace}"
        app = "${var.app}"
        app_shortname = "${var.app_shortname}"
        contact = "${var.contact}"
        contact_details = "${var.contact_details}"
        costcentre = "${var.costcentre}"
        description = "${var.description}"
        location = "${var.azure_region}"    
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
    }

    app_service_plan_id = "/subscriptions/${var.subscription_id}/resourceGroups/apps-shared-rg-uks-${terraform.workspace}/providers/Microsoft.Web/serverfarms/apps-shared-appsp-${terraform.workspace}"
    
    storage_account_name = "userpreffncstruks${terraform.workspace}"

    beas_app_name = "beas-func-${terraform.workspace}"

    user_preference_service_function_name = "${lookup(local.tags,"app")}-${lookup(local.postfixes,"function")}-${terraform.workspace}"
    
    app_insights_name = "${lookup(local.tags,"app")}-${lookup(local.postfixes,"app_insights")}-${terraform.workspace}"

    sql_svr_name = "${lookup(local.tags,"project")}-${lookup(local.tags,"app_shortname")}-${lookup(local.postfixes,"sql_server")}-${terraform.workspace}"

    sql_svr_db_name = "${lookup(local.tags,"app_shortname")}-${lookup(local.postfixes,"sql_database_main_instance")}-${terraform.workspace}"

    key_vault_name = "${lookup(local.tags,"app_shortname")}-${lookup(local.postfixes,"key_vault")}-${terraform.workspace}"
    ad_group_name = "${lookup(local.tags,"app_shortname")}-group-${terraform.workspace}"
    ad_admin_group_name = "${lookup(local.tags,"app_shortname")}-group-${terraform.workspace}-admin"
    ad_read_group_name = "${lookup(local.tags,"app_shortname")}-group-${terraform.workspace}-read"
    ad_write_group_name = "${lookup(local.tags,"app_shortname")}-group-${terraform.workspace}-write"

}

