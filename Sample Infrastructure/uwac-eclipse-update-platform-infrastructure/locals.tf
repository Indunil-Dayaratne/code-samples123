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
    
    storage_account_name = "${var.app_short_name}funcstorageuks${terraform.workspace}"

    validator_function_name = "${lookup(local.tags,"app")}-validator-${lookup(local.postfixes,"function")}-${terraform.workspace}"
    mapper_function_name = "${lookup(local.tags,"app")}-mapper-${lookup(local.postfixes,"function")}-${terraform.workspace}"
    signalr_name = "${lookup(local.tags,"app")}-${lookup(local.postfixes,"signalr")}-${terraform.workspace}"

    app_insights_name = "${lookup(local.tags,"app")}-${lookup(local.postfixes,"app_insights")}-${terraform.workspace}"

    app_service_plan_id = "/subscriptions/${var.subscription_id}/resourceGroups/apps-shared-rg-uks-${terraform.workspace}/providers/Microsoft.Web/serverfarms/apps-shared-appsp-${terraform.workspace}"

    key_vault_name = "${lookup(local.tags,"app")}-${lookup(local.postfixes,"key_vault")}-${terraform.workspace}"
}

