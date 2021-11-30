platform_state_key_name="platform.terraform.tfstate"
platform_state_container_name="terraform-container-ukw-prod"
platform_state_storage_account_name="terraformukwprod"
platform_state_resource_group_name = "terraform-rg-ukw-prod"

azure_short_region = "uks"
azure_region = "UK South"

project = "Azure VM Schedule Monitor"
app = "azurevmschedulemonitor"
storage = "schedulemonitorstore"
tablestore = "schedulemonitortablestore"
contact = "Harry Hall"
contact_details = "ext 100684"
costcentre = "N37"
description = "Azure VM automatic start-up/shut-down schedule monitor"
environment = "prod"

app_service_plan_sku_tier = "Standard"
app_service_plan_sku_size = "S2"
app_service_plan_sku_capacity = "1"

app_service_plan_reserved = "true"
app_service_plan_kind = "Linux"

app_service_site_config = {
    python_version = "3.4"
    always_on = "true"
    app_command_line = "startup.txt"
    websockets_enabled = "true"
}

storage_account_tier = "Standard"
storage_account_replication_type = "LRS"