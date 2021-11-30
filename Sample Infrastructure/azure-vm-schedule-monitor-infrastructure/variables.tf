
variable "environment" {
    description = "The shortname for the environment - TODO - Change this to a map"
}
variable "project" {
  description = "Enter the name of the project"
}

variable "app" {
  description = "Enter the name of the app (lower case characters only)"
}

variable "tablestore" {
  description = "Name of the table storage acoount"  
}

variable "storage" {
  description = "Name of the storage account"
}

variable "contact" {
  description = "Contact name for the application"
}

variable "contact_details" {
  description = "Contact informations details"
}

variable "costcentre" {
  description = "Enter the cost centre ID"
}

variable "description" {
  description = "A description for the application"
}
variable "azure_short_region" {
    description = "Define the short name for the region e.g. weu."
}
variable "azure_region" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}

variable "platform_state_key_name" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}

variable "platform_state_container_name" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}

variable "platform_state_storage_account_name" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}

variable "platform_state_resource_group_name" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}

variable "app_service_site_config" {
  type = "map"
}

variable "app_service_plan_reserved" {
  description = "App service Plan reserved - Linux = true, Windows = false"
}

variable "app_service_plan_kind" {
  description = "App Service Plan Kind - Linux or Windows"
}

variable "storage_account_tier" {
  description = "Account tier for the storage account"
}

variable "storage_account_replication_type" {
  description = "Storage account replication type"
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
}

variable "tags" {
  type        = "map"
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}