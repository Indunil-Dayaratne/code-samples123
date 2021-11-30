data "azurerm_resource_group" "rg" {
  name     = "${local.resource_group_name}-${var.azure_short_region}-${terraform.workspace}"
}

resource "azurerm_resource_group" "rg_dr" {
  name     = "${local.resource_group_name}-${var.azure_short_region_dr}-${terraform.workspace}"
  location = var.azure_region_dr
  tags     = local.tags_dr
}