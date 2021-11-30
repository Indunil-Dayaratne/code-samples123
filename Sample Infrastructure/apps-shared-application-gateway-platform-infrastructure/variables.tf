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

variable "description" {
  description = "A description for the application"
}
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

variable "tenant_id" {
  description = "The Azure Tenant Id"
}

variable "spn_app_id" {
  description = "The Azure App Id that will add secrets to KV"
}

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

variable "environment_postfix" {
  description = "The environment postfix to be appended to resource names"
}

variable "apis" {
    type = list(string)
    description = "list of APIs to be exposed via the Application Gateway"
}

variable "api_resource_groups" {
    type = list(string)
    description = "list of resource group names for each API to be exposed via the Application Gateway. This list should have the same number of elements as the 'apis' list"
}

variable "apiCount" {
    description = "count of APIs to be exposed via the Application Gateway"
}