data "azurerm_resource_group" "rg" {
  name     = "uwac-beas-rg-${var.azure_short_region}-${terraform.workspace}"
}

data "azurerm_resource_group" "rg_dr" {
  name     = "uwac-beas-rg-${var.azure_short_region_dr}-${terraform.workspace}"
}