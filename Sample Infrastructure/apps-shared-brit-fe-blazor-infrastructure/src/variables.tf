variable "enabled" {
  type        = string
  description = "Enables all the infrastructure to be deployed when 'true'. Destroys infrastructure when 'false'."
}

variable "azure_short_region" {
  type        = string
  description = "Define the short name for the region e.g. uks."
}
variable "azure_region" {
  type        = string
  description = "Azure region the resource is located, this is the full region name e.g. UK South."
}

variable "azure_short_region_dr" {
  type        = string
  description = "Define the short name for the dr region e.g. uks."
}
variable "azure_region_dr" {
  type        = string
  description = "Azure region the dr resource is located, this is the full region name e.g. UK South."
}

variable "dr_enabled" {
  type        = string
  description = "If this > 0, DR recovery region components will be deployed. Preferrably on PRD and TST."
}

variable "appsp_tier" {
  type        = string
  description = "App Service Plan Tier. E.g. Free, Basic, Standard, etc"
}
variable "appsp_size" {
  type        = string
  description = "App Service Plan Size. E.g. F1/B1/S1/P1, etc"
}
variable "appsp_kind" {
  type        = string
  description = "App Service Plan Kind. E.g. Windows, Linux, elastic, and FunctionApp"
}