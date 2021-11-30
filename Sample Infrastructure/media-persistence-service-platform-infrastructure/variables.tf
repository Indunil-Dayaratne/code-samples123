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
variable "tags" {
  type        = "map"
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}

variable "admin_username" {
  description = "The admin username of the VM that will be deployed"
  default     = "azureuser"
}
variable "admin_password" {
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure"
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

variable "app_service_plan_id" {
  description = "The id of the Shared App Service Plan for the given environment"
}

variable "common_shared_services_resource_group_name" {
  description = "The shared services resource group name"
}

variable "cosmosdb_account_name" {
  description = "The CosmosDB account name"
}

variable "cosmosdb_database_name" {
  description = "The CosmosDB database name"
}

variable "subcategory" {
  description = "The project subcategory name"
}