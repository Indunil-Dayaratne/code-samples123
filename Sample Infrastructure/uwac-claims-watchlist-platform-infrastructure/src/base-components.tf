resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_group_name}-${var.azure_short_region}-${terraform.workspace}"
  location = var.azure_region
  tags     = local.tags
}

resource "azurerm_resource_group" "rg_dr" {
  count    =  var.dr_resource_count
  name     = "${local.resource_group_name}-${var.azure_short_region_dr}-${terraform.workspace}"
  location = var.azure_region_dr
  tags     = local.tags_dr
}

resource "azurerm_application_insights" "appins" {
  name                =  "${local.app_insights_name}-${var.azure_short_region}-${terraform.workspace}"
  location            =  var.azure_appins_region
  resource_group_name =  azurerm_resource_group.rg.name
  application_type    = "web"
  tags                = local.tags
}

resource "azurerm_application_insights" "appins_dr" {
  count				        =  var.dr_resource_count  // Deploy in case of TEST and PROD
  name                =  "${local.app_insights_name}-${var.azure_short_region_dr}-${terraform.workspace}"
  location            =  var.azure_appins_region
  resource_group_name =  azurerm_resource_group.rg_dr[count.index].name
  application_type    = "web"
  tags                = local.tags_dr
}