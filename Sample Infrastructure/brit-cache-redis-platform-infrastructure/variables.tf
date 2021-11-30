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

variable "project" {
  description = "Enter the name of the project"
}

variable "app" {
  description = "Enter the name of the app (lower case characters only)"
}

variable "app_shortname" {
  description = "Enter the short name of the app (lower case characters only)"
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

variable "dr" {
  description = "DR setup. boolean value"
  default     = "0"
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
variable "azure_short_region_ukw" {
    description = "Define the short name for the region e.g. weu."
}
variable "azure_region_ukw" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}
variable "tags" {
  type        = "map"
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}


variable "tenant_id" {
  description = "The Azure Tenant Id"
}

# variable "spn_app_id" {
#   description = "The Azure App Id that will add secrets to KV"
# }

variable "spn_object_id" {
  description = "The Azure App Object Id that will add secrets to KV"
}

# variable "app_service_plan_id" {
#   description = "The id of the Shared App Service Plan for the given environment"
# }

variable "subscription_id" {
  description = "The Azure Subscription ID"
}

variable "subcategory" {
  description = "The project subcategory name"
}

variable "capacity" {
  description = "The Capacity of redis cache eg, 0, 1 ,2"
}

variable "family" {
  description = "The redis family eg. C, P"
}

variable "sku_name" {
  description = "The Sku name for redis eg- basic, standard, premium"
}

variable "capacity_ukw" {
  description = "The Capacity of redis cache eg, 0, 1 ,2"
}

variable "family_ukw" {
  description = "The redis family eg. C, P"
}

variable "sku_name_ukw" {
  description = "The Sku name for redis eg- basic, standard, premium"
}



