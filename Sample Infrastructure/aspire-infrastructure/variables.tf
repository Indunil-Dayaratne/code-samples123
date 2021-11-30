#Platform
variable "azure_short_region" {
    description = "Define the short name for the region e.g. weu."
}

variable "azure_region" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}

variable "platform_state_key_name" {
    description = "Platform state key name."
}

variable "platform_state_container_name" {
    description = "Platform state container name."
}

variable "platform_state_storage_account_name" {
    description = "Platform state storage account name."
}

variable "platform_state_resource_group_name" {
    description = "Platform state resource group name."
}

variable "aspire_db_server_admin_password" {
    description = "Password for the cloudadmin account on the Aspire SQL DB server."
}

variable "app_service_plan_name" {
    description = "Name of the app service plan that will host the Aspire App Service."    
}

variable "app_service_plan_resource_group_name" {
    description = "Resource group of the app service plan that will host the Aspire App Service."
}

variable "aspire_vnet_name" {
    description = "Name of the vnet for the SSIS Managed Runtime host."
}

variable "aspire_vnet_resource_group_name" {
    description = "The Aspire vnet's resource group name."
}

variable "aspire_subnet_cidr" {
    description = "Address range for the Aspire subnet."
}