module "beas_apim" {
  source                    = "../../terraform-modules/modules/azurerm_api_management_api"
  apim = {
    resource_group_name     = var.apim.resource_group
    name                    = var.apim.name
  }
  region = {
     location               = var.azure_region
     location_dr            = var.azure_region_dr
     location_short_name    = var.azure_short_region
     location_short_name_dr = var.azure_short_region_dr
  }
  api = {
    name                    = "beas-${terraform.workspace}"
    content_format          = "openapi+json-link"
    primary_base_url        = "https://${local.beas_function_name}.azurewebsites.net/api" 
    secondary_base_url      = "https://${local.beas_function_name_dr}.azurewebsites.net/api"
    rewrite_url             = ""
    swagger_url             = "https://${local.swagger_func_name}.azurewebsites.net/api/swagger/beasapi/json"
    relative_path           = "beas-${terraform.workspace}"
    cors_origins            = var.cors
  }
  swagger_api = {
    resource_group_name     = local.swagger_resource_group_name
    key_vault_name          = local.swagger_key_vault_name
    entity_name             = "beasapi"
    swagger_url             = "https://${local.beas_function_name}.azurewebsites.net/api/swagger/json"
    client_id               = data.azuread_application.api_aad.application_id
  }
}

