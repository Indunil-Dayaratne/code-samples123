locals {
    api_aad_name = "beas-func-${terraform.workspace}"    
    swagger_func_name = "swagger-api-func-${var.azure_short_region}-${terraform.workspace}"
    swagger_key_vault_name = "swagger-kv-${var.azure_short_region}-${terraform.workspace}"
    swagger_resource_group_name = "uwac-swagger-rg-${var.azure_short_region}-${terraform.workspace}"
    beas_function_name = "beas-func-${terraform.workspace}"
    beas_function_name_dr = "beas-func-${terraform.workspace}-01"
}
