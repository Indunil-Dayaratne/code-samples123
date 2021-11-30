variable "azure_short_region_dr" {
    description = "Define the short name for the region e.g. weu."
}

variable "azure_region_dr" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}

variable "primary" {
    type = object({
        resource_group = string
        azure_region = string
        azure_short_region = string
    })
}