locals {
    resource_group_name = "${lookup(local.tags,"project")}-${lookup(local.tags,"app_shortname")}-rg-${var.azure_short_region}-${terraform.workspace}"
    resource_group_name_ukw = "${lookup(local.tags,"project")}-${lookup(local.tags,"app_shortname")}-rg-${var.azure_short_region_ukw}-${terraform.workspace}"

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

    tags_ukw = {
        project = "${var.project}"
        environment = "${terraform.workspace}"
        app = "${var.app}"
        app_shortname = "${var.app_shortname}"
        contact = "${var.contact}"
        contact_details = "${var.contact_details}"
        costcentre = "${var.costcentre}"
        description = "${var.description}"
        location = "${var.azure_region_ukw}"    
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
        redis_cache = "redis"
    }
	
    redis_cache_name = "${lookup(local.tags,"app_shortname")}-${lookup(local.postfixes,"redis_cache")}-${terraform.workspace}"
    redis_cache_name_ukw = "${lookup(local.tags,"app_shortname")}-${lookup(local.postfixes,"redis_cache")}-ukw-${terraform.workspace}"
    ukw_resource_count = "${var.dr}"
}

