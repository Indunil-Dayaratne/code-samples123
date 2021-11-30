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

variable "subscription_id" {
  description = "The Azure Subscription Id in which the resources need to be created"
}
