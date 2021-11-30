//module "api_apim" {
//  #if running TF locally, please clone it to a sibling directory of the repo
//  source                    = "../../terraform-modules/modules/azurerm_api_management_api"
//  apim = {
//    resource_group_name     = var.apim.resource_group
//    name                    = var.apim.name
//  }
//  region = {
//     location               = var.azure_region
//     location_dr            = var.azure_region_dr
//     location_short_name    = var.azure_short_region
//     location_short_name_dr = var.azure_short_region_dr
//  }
//  api = {
//    name                    = "eclipse-risk-api-${terraform.workspace}"
//    content_format          = "openapi+json-link"
//    primary_base_url        = "https://${azurerm_function_app.api_func.name}.azurewebsites.net/api" 
//    secondary_base_url      = "https://${azurerm_function_app.api_func_dr.name}.azurewebsites.net/api"
//    rewrite_url             = "api/"
//    swagger_url             = "https://${azurerm_function_app.api_func.name}.azurewebsites.net/api/swagger/json"
//    relative_path           = "eclipse-risk-api-${terraform.workspace}"
//    cors_origins            = []
//  }
//  swagger_api = {
//    resource_group_name     = local.swagger_resource_group_name
//    key_vault_name          = local.swagger_key_vault_name
//    entity_name             = "EclipseRiskApi"
//    swagger_url             = "https://${azurerm_function_app.api_func.name}.azurewebsites.net/api/swagger/json"
//    client_id               = azuread_application.api_aad.application_id
//  }
//}

//module "validation_apim" {
//  source                    = "../../terraform-modules/modules/azurerm_api_management_api"
//  apim = {
//    resource_group_name     = var.apim.resource_group
//    name                    = var.apim.name
//  }
//  region = {
//     location               = var.azure_region
//     location_dr            = var.azure_region_dr 
//     location_short_name    = var.azure_short_region
//     location_short_name_dr = var.azure_short_region_dr
//  }
//  api = {
//    name                    = "eclipse-risk-validator-${terraform.workspace}"
//    content_format          = "openapi+json-link"
//    primary_base_url        = "https://${azurerm_function_app.validator_func.name}.azurewebsites.net/api" 
//    secondary_base_url      = "https://${azurerm_function_app.validator_func_dr.name}.azurewebsites.net/api"
//    rewrite_url             = "api/"
//    swagger_url             = "https://${azurerm_function_app.validator_func.name}.azurewebsites.net/api/swagger/json"
//    relative_path           = "eclipse-risk-validator-${terraform.workspace}"
//    cors_origins            = []
//  }
//  swagger_api = {
//    resource_group_name     = local.swagger_resource_group_name
//    key_vault_name          = local.swagger_key_vault_name
//    entity_name             = "EclipseRiskValidator"
//    swagger_url             = "https://${azurerm_function_app.validator_func.name}.azurewebsites.net/api/swagger/json"
//    client_id               = azuread_application.val_aad.application_id
//  }
//}