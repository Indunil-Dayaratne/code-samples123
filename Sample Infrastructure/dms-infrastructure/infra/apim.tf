 module "dms_sponlinegateway_apim" {
    source                    = "../../terraform-modules/modules/azurerm_api_management_api"
    apim = {
      resource_group_name     = var.apim.resource_group
      name                    = var.apim.name
    }
    region = {
       location               = var.apim.location
       location_dr            = var.apim.location_dr
       location_short_name    = var.apim.region
       location_short_name_dr = var.apim.region_dr
    }
    api = {
      name                    = "dms-sponlinegateway-${local.tags.environment}"
      content_format          = "openapi+json-link"
      primary_base_url        = "https://${var.apim.spgateway_webapp_name}.azurewebsites.net" 
      secondary_base_url      = "https://${var.apim.spgateway_webapp_name_dr}.azurewebsites.net"
      rewrite_url             = ""
      swagger_url             ="https://${var.apim.spgateway_webapp_name}.azurewebsites.net/swagger/docs/v1"
      relative_path           = "dms-sponline-${terraform.workspace}"
      cors_origins            = var.cors
    }
    swagger_api = {
      resource_group_name     = var.apim.swagger_resource_group_name
      key_vault_name          = var.apim.swagger_key_vault_name
      entity_name             = "dms-sponlinegateway"
      swagger_url             = "https://${var.apim.spgateway_webapp_name}.azurewebsites.net/swagger/docs/v1"
      client_id               = ""
    }
  }
