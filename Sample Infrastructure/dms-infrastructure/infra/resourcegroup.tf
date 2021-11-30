resource "azurerm_resource_group" "rg" {
    name        = "${local.tags.app}-rg-${local.region}-${terraform.workspace}"
    location    = local.tags.location
    tags        = local.tags
}

resource "azurerm_resource_group" "rgdr" {
    count       = var.DrResource.ResourceCount
    name        = "${local.tags.app}-rg-${local.region_dr}-${terraform.workspace}"
    location    = local.tags.location_dr
    tags        = local.tags
}

resource "azurerm_resource_group" "rgtst" {
    count       = terraform.workspace == "uat" ? 1 : 0
    name        = "${local.tags.app}-rg-${local.region}-tst"
    location    = local.tags.location
    tags        = local.tags
}

resource "azurerm_resource_group" "rgstg" {
    count       = terraform.workspace == "uat" ? 1 : 0
    name        = "${local.tags.app}-rg-${local.region}-stg"
    location    = local.tags.location
    tags        = local.tags
}