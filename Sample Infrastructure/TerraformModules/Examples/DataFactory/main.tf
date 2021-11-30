resource "azurerm_resource_group" "rg" {
    name                    = "${var.Tags["App"]}-rg-${local.region}-${terraform.workspace}"
    location                = var.Location
    tags                    = var.Tags
}

data "azurerm_virtual_network" "vnet" {
    name                    = var.Network["Name"]
    resource_group_name     = var.Network["Group"]
}

resource "azurerm_subnet" "snet" {
    name                    = "${var.Tags["App"]}-sn-${local.region}-${terraform.workspace}"
    resource_group_name     = var.Network["Group"]
    virtual_network_name    = var.Network["Name"]
    address_prefixes        = [var.Network["Subnet"]]
}

module "data_factory" {
    source                  = "../../Modules/DataFactory"

    Project                 = var.Tags["App"]
    ResourceGroup           = azurerm_resource_group.rg.name
    Location                = var.Location
    Tags                    = var.Tags
    Environment             = terraform.workspace
    FactoryCount            = var.FactoryCount
    Runtime                 = local.runtime
}
