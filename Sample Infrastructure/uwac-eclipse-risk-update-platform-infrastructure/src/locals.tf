locals {

    tags = {
        project = "uwac"
        environment = terraform.workspace
        app = "eclipse-update"
        contact = "Ahmet Demir"
        contact_details = "ext 10129"
        costcentre = "N37"
        description = "Azure Table Storage resource in the ESB Storage account"
        location = var.azure_region   
        project_subcategory = "Opus-PaaS"
        business_name = "Opus"
        Application = "OPUS"
    }

    tags_dr = {
        project = "uwac"
        environment = terraform.workspace
        app = "eclipse-update"
        contact = "Dilip Hirani"
        contact_details = "dilip.hirani@britinsurance.com"
        costcentre = "N37"
        description = "Process eclipse risk updates"
        location = var.azure_region_dr 
        project_subcategory = "Opus-PaaS"
        business_name = "Opus"
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

    environments = {
        dev = "dev"
        tst = "test"
        uat = "uat"
        stg = "stg"
        prd = "prd"
    }

    resource_group_name = "uwac-eclipse-update-rg"
    mapper_func_name =  "eclipse-risk-mapper-func-${var.azure_short_region}-${terraform.workspace}"
    validator_func_name =  "eclipse-risk-validator-func"
    api_func_name = "eclipse-risk-api-func"
    key_vault_name = "eclipse-update-kv-${terraform.workspace}"
    mapper_aad_name = "eclipse-risk-mapper-func-${terraform.workspace}"
    validator_aad_name = "eclipse-risk-validator-func-${terraform.workspace}"
    api_aad_name = "eclipse-api-func-${terraform.workspace}"
    notify_aad_name = "esb-notification-func-${lookup(local.environments, terraform.workspace)}"
    notify_func_name = "esb-notification-func-${lookup(local.environments, terraform.workspace)}"
    app_service_plan = "eclipse-risk-appsp"
    beas_app_name = "beas-func-${terraform.workspace}"   
    britcache_app_name = "britcache-api-eclipse-func-${terraform.workspace}"
    swagger_func_name = "swagger-api-func-${var.azure_short_region}-${terraform.workspace}"
    swagger_key_vault_name = "swagger-kv-${var.azure_short_region}-${terraform.workspace}"
    swagger_resource_group_name = "uwac-swagger-rg-${var.azure_short_region}-${terraform.workspace}"
}
