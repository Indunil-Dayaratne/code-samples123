data "azurerm_application_insights" "appins" {
  name                = "opusweb-appins-${local.region}-${terraform.workspace}"
  resource_group_name = data.azurerm_resource_group.rg.name  
}

data "azurerm_application_insights" "appins_dr" {
  count               = "${var.Resource_Dr.ResourceCount}"
  name                = "opusweb-appins-${local.region_dr}-${terraform.workspace}"
  resource_group_name = data.azurerm_resource_group.rg_dr[0].name  
}

