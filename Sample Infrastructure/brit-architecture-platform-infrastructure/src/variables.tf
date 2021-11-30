variable "azure_short_region_dr" {
    description = "Define the short name for the region e.g. weu."
}

variable "azure_region_dr" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}

variable "admin_username" {
  description = "The admin username of the SQL Server that will be deployed"
  default     = "azureuser"
}
variable "admin_password" {
  description = "The admin password to be used on the SQL Server that will be deployed. The password must meet the complexity requirements of Azure"
}

variable "tenant_id" {
  description = "The Azure Tenant Id"
}

variable "primary" {
    type = object({
        resource_group = string
        azure_region = string
        azure_short_region = string
    })
}