variable "apim" {
  type = object({
    resource_group_name = string
    name = string
  })
}

variable "region" {
 type = object({
      location = string
      location_dr = string
      location_short_name = string
      location_short_name_dr = string
    })
}

variable "api" {
  type = object({
    name = string
    content_format = string
    primary_base_url = string
    secondary_base_url = string
    rewrite_url = string
    swagger_url = string
    relative_path = string
    cors_origins = list(string)
  })
}

variable "swagger_api" {
  type = object({
    key_vault_name = string
    resource_group_name = string
    entity_name = string
    swagger_url = string
    client_id = string
  })
}
