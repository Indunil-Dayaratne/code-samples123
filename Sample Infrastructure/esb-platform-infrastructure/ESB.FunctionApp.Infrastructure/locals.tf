locals {
    resource_group_name = "rg-${terraform.workspace}-${var.app}-${var.azure_short_region}-01"

    tags = {
        project = "${var.project}"
        environment = "${terraform.workspace}"
        app = "${var.app}"
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
        signalr = "signalr"
    }

    storage_account_name = "esbfuncstorageuks${terraform.workspace}"
    notification_function_name = "${lookup(local.tags,"app")}-notification-${lookup(local.postfixes,"function")}-${terraform.workspace}"
    signalr_name = "${lookup(local.tags,"app")}-notification-${lookup(local.postfixes,"signalr")}-${terraform.workspace}"
    app_insights_name = "${lookup(local.tags,"app")}-notification-${lookup(local.postfixes,"app_insights")}-${terraform.workspace}"
    app_service_plan_id = "/subscriptions/${var.subscription_id}/resourceGroups/apps-shared-rg-uks-${terraform.workspace}/providers/Microsoft.Web/serverfarms/apps-shared-appsp-${terraform.workspace}"    
}

