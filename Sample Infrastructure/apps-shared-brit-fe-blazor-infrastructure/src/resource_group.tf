resource "azurerm_resource_group" "rg" {
  count     = var.enabled == "true" ? 1 : 0
  name      = "${local.resource_group_name}-${var.azure_short_region}-${terraform.workspace}"
  location  = var.azure_region
  tags      = local.tags
}

resource "azurerm_resource_group" "rg_dr" {
  count     = var.enabled == "true" && var.dr_enabled == "true" ? 1 : 0
  name      = "${local.resource_group_name}-${var.azure_short_region_dr}-${terraform.workspace}"
  location  = var.azure_region_dr
  tags      = local.tags_dr
}