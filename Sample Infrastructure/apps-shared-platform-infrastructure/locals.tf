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
        business_name = "uwac"
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
    }

    api_app_plan={
        dev=0
        tst=0
        int=0
        stg=0
        uat=0
        chg=0
        dmo=0
        prd=1
    }

    app_service_plan_name = "${lookup(local.tags,"project")}-${lookup(local.tags,"app")}-${lookup(local.postfixes,"app_service_plan")}-${terraform.workspace}"
    api_app_service_plan_name = "${lookup(local.tags,"project")}-${lookup(local.tags,"app")}-api-${lookup(local.postfixes,"app_service_plan")}-${terraform.workspace}"
    key_vault_name = "${lookup(local.tags,"project")}-${lookup(local.tags,"app")}-${lookup(local.postfixes,"key_vault")}-${terraform.workspace}"
    api_app_service_plan_count = "${lookup(local.api_app_plan,"${terraform.workspace}")}"
}

