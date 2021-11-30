locals {
    platform_resource_group_name = "platform-rg-${var.azure_short_region}-${var.environment_postfix}"
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
        storage = "store"
        signalr = "signalr"
        api_management = "apimgmt"
        func_api = "funcapi"
        redis_cache = "redis"
        application_gateway = "agw"
    }

    opusweburlpostfix = {
        default=""
        dev="-dev"
        tst="-test"
        stg="-staging"
        uat="-uat"
        prd=""
    }

    subnet_address_space = {
        nonprod = "10.9.91.0/24"
        prod = "10.8.91.0/24"
    }

    app_gateway_name = "${var.project}-${var.app_shortname}-agw-${var.azure_short_region}-${var.environment_postfix}"
    subnet_address_prefix = "${lookup(local.subnet_address_space,"${var.environment_postfix}")}"
    cors_origin = "https://opus${lookup(local.opusweburlpostfix,"${terraform.workspace}")}"    
    
}

