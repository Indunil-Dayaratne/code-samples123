data "azurerm_application_insights" "appins" {
  name                = "eclipse-update-appins-${terraform.workspace}"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_application_insights" "appins_dr" {
  name                =  "eclipse-update-appins-${var.azure_short_region_dr}-${terraform.workspace}"
  location            =  azurerm_resource_group.rg_dr.location
  resource_group_name =  azurerm_resource_group.rg_dr.name
  application_type    = "web"
  tags                = local.tags_dr
}