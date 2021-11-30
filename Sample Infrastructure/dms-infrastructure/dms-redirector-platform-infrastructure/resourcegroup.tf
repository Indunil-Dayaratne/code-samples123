data "azurerm_resource_group" "rg" {
    name        = "${local.tags.app_group}-rg-${local.region}-${terraform.workspace}"    
}

data "azurerm_resource_group" "rg_dr" {
    count       = "${var.Resource_Dr.ResourceCount}"
    name        = "${local.tags.app_group}-rg-${local.region_dr}-${terraform.workspace}"    
}