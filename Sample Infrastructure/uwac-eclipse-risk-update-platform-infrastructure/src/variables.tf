variable "azure_short_region" {
    description = "Define the short name for the region e.g. weu."
}
variable "azure_region" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}

variable "azure_short_region_dr" {
    description = "Define the short name for the dr region e.g. weu."
}
variable "azure_region_dr" {
    description = "Azure region the dr resource is located, this is the full region name e.g. West Europe."
}

variable "esb" {
    type = object({
      resource_group = string
      storage_account = string
      service_bus = string
    })
}

variable "shared" {
    type = object({
      app_service_plan = string
      resource_group = string
    })
}

variable "shared_dr" {
    type = object({
      app_service_plan = string
      resource_group = string
    })
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

variable "subnet" {
    type = object({
      name = string
      resource_group = string
      vnet_name = string
    })
}

variable "subnet_dr" {
    type = object({
      name = string
      resource_group = string
      vnet_name = string
    })
}

variable "apim" {
  type = object({
    resource_group = string
    name = string
    base_url = string
  })
}

variable "eclipse_base_url" {
    type = string
}

variable "service_account_name"{
  type=string
}