resource "azurerm_resource_group" "rg_dr" {
  name     = "${local.resource_group_name}-${var.azure_short_region_dr}-${terraform.workspace}"
  location = var.azure_region_dr
  tags     = local.tags_dr
}

data "azurerm_resource_group" "rg" {
  name  = var.primary.resource_group
}
