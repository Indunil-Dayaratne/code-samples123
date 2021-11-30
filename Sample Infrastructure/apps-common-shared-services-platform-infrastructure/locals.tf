locals {
    resource_group_name = "${lookup(local.tags,"project")}-${lookup(local.tags,"app")}-rg-${var.azure_short_region}-${terraform.workspace}"

    tags = {
        project = "${var.project}"
        environment = "${terraform.workspace}"
        app = "${var.app}"
        app_short_name = "${var.app_short_name}"
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
        api_management = "apimgmt"
        cosmos_db = "cosmos"
		brit = "brit"
    }

    front_door_name = "brit-front-door-${terraform.workspace}"
    key_vault_name = "${lookup(local.postfixes,"brit")}-${lookup(local.tags,"app_short_name")}-${lookup(local.postfixes,"key_vault")}-${terraform.workspace}"
    cosmos_db_name = "${lookup(local.tags,"project")}-${lookup(local.tags,"app_short_name")}-${lookup(local.postfixes,"cosmos_db")}-${terraform.workspace}"
	cosmos_db_prefix = "${var.project}-cosmos-db-${var.azure_short_region}-${terraform.workspace}"
}

