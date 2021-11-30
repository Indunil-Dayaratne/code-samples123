variable "azure_short_region" {
    description = "Define the short name for the region e.g. uks."
}
variable "azure_region" {
    description = "Azure region the resource is located, this is the full region name e.g. UK South."
}

variable "azure_short_region_dr" {
    description = "Define the short name for the dr region e.g. ukw."
}
variable "azure_region_dr" {
    description = "Azure region the dr resource is located, this is the full region name e.g. UK West."
}

variable "apim" {
  type = object({
    resource_group = string
    name = string
    base_url = string
  })
}
  
variable "cors" {
  type = list(string)
}
