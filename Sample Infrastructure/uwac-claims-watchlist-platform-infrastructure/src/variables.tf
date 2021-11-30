variable "azure_short_region" {
    description = "Define the short name for the region e.g. weu."
}

variable "azure_region" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}

variable "azure_short_region_dr" {
    description = "Define the short name for the region e.g. weu."
}

variable "azure_region_dr" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}

variable "azure_appins_region" {
    description = "Azure region the app insights is located, this is the full region name e.g. West Europe."
}

variable "dr_resource_count" {
    description = "If this count > 0, recovery region components will be deployed. Preferrably on PROD and TEST."
}

variable "beas_base_url" {
  description = "beas base url"
}

variable "cosmos_database_endpoint_url" {
  description = "cosmos database endpoint url"
}

variable "britcache_api_base_url" {
  description = "britcache api base url"
}

variable "common_shared" {
    type = object({
      storage_account = string
      resource_group = string
    })
}
variable "common_shared_dr" {
    type = object({
      storage_account = string
      resource_group = string
    })
}

variable "cors" {
	type =  list(string)
}

variable "reply_urls" {
	type =  list(string)
}

variable "shared" {
    type = object({
      app_service = string
      resource_group = string
    })
}

variable "shared_dr" {
    type = object({
      app_service = string
      resource_group = string
    })
}

variable "cosmos" {
    type = object({
      account_name = string
      db_name = string
      resource_group = string
    })
}

variable "user_preferences" {
    type = object({
      preference_key = string
      preference_key_id = number
      grid_preference_key = string
      grid_preference_key_id = number
    })
}