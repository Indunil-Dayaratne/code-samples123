locals {
    resource_group_name = "${lookup(local.tags,"project")}-${lookup(local.tags,"app_shortname")}-rg-${var.azure_short_region}-${local.env_postfix}"    
    
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

    customdomainprefix = {
        default="api"
        tst="api-test"
        prd="api"
    }

    environmentpostfix = {
        default = "tst"
        prod = "prd"
        nonprod = "tst"
    }

    apimresourcecount = {
        default = "0"
        dev = "0"
        tst = "1"
        chg = "0"
        int = "0"
        uat = "0"
        stg = "0"
        dmo = "0"
        prd = "1"
    }

    apimdatasourcecount = {
        default = "1"
        dev = "1"
        tst = "0"
        chg = "1"
        int = "1"
        uat = "1"
        stg = "1"
        dmo = "1"
        prd = "0"
    }

    apimresource = "${lookup(local.apimresourcecount, "${terraform.workspace}")}"
    apimdatasource = "${lookup(local.apimdatasourcecount, "${terraform.workspace}")}" 
    env_postfix = "${lookup(local.environmentpostfix, "${var.environment_type}")}"
    apim_name = "${lookup(local.tags,"project")}-${lookup(local.tags,"app_shortname")}-${lookup(local.postfixes,"api_management")}-${local.env_postfix}"
    custom_domain_hostname_brit = "${lookup(local.customdomainprefix, local.env_postfix)}.britinsurance.com"
    custom_domain_hostname_ki = "${lookup(local.customdomainprefix, local.env_postfix)}.ki-insurance.com"
    certificate_name_brit = "${lookup(local.customdomainprefix, local.env_postfix)}-britinsurance"
    certificate_name_ki = "${lookup(local.customdomainprefix, local.env_postfix)}-ki-insurance"
    cors_origin = "https://opus${lookup(local.opusweburlpostfix, local.env_postfix)}"    
    kv_name = "${lookup(local.tags,"project")}-${lookup(local.tags,"app_shortname")}-${lookup(local.postfixes,"key_vault")}-${local.env_postfix}"
}

