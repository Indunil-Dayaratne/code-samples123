resource "azurerm_application_insights" "appins" {
  name                = "opusweb-appins-${local.region}-${terraform.workspace}"
  location            = local.tags.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  tags                = local.tags
}

resource "azurerm_application_insights" "appinsdr" {
  count               = var.DrResource.ResourceCount
  name                = "opusweb-appins-${local.region_dr}-${terraform.workspace}"
  location            = local.tags.location_dr
  resource_group_name = azurerm_resource_group.rgdr[0].name
  application_type    = "web"
  tags                = local.tags
}

resource "azurerm_application_insights" "appinstst" {
  count               = terraform.workspace == "uat" ? 1 : 0
  name                = "opusweb-appins-${local.region}-tst"
  location            = local.tags.location
  resource_group_name = "${local.tags.app}-rg-${local.region}-tst"
  application_type    = "web"
  tags                = local.tags
}

resource "azurerm_application_insights" "appinsstg" {
  count               = terraform.workspace == "uat" ? 1 : 0
  name                = "opusweb-appins-${local.region}-stg"
  location            = local.tags.location
  resource_group_name = "${local.tags.app}-rg-${local.region}-stg"
  application_type    = "web"
  tags                = local.tags
}