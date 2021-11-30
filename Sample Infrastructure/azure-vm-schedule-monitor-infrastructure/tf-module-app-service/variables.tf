variable "resource_group_location" {
    description = "Resource group location"
}

variable "environment" {
    description = "The shortname for the environment - TODO - Change this to a map"
}

variable "app_service_plan_sku_tier" {
  description = "SKU tier of the App Service Plan"
  default = "Standard"
}

variable "app_service_plan_sku_size" {
  description = "SKU size of the App Service Plan"
  default = "S1"
}

variable "app_service_plan_sku_capacity" {
  description = "app service sku capacity"
  default = "1"
}

variable "app_service_client_affinity_enabled" {
  description = "app service client affinity"
  default = "true"
}

variable "app_service_enabled" {
  description = "app service enabled"
  default = "true"
}

variable "azure_short_region" {
    description = "Define the short name for the region e.g. weu."
}

variable "resource_group_name" {
  description = "Name of the resource group"
}


variable "resource_prefix" {
  description = "App Service host prefix (to identify what this is)"
}


variable "app_service_plan_reserved" {
  description = "App service Plan reserved - Linux = true, Windows = false"
  default = "false"
}

variable "app_service_plan_kind" {
  description = "App Service Plan Kind - Linux or Windows"
  default = "Windows"
}

variable "app_service_site_config" {
  type = "map"
    default = {
    dotnet_framework_version = "v4.0"
  }
}

variable "tags" {
  type        = "map"
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}

