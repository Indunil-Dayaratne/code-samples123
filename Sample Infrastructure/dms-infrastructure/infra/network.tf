data "azurerm_route_table" "rt" {
    name                            = var.Network.RouteTable.Name
    resource_group_name             = var.Network.RouteTable.ResourceGroup
}

data "azurerm_network_security_group" "nsg" {
    name = var.Network.Nsg.Name
    resource_group_name = var.Network.Nsg.ResourceGroup
}

resource "azurerm_subnet" "snet" {
    name                            = "${local.tags.app}-sn-${terraform.workspace}"
    virtual_network_name            = var.Network.Vnet.Name
    resource_group_name             = var.Network.Vnet.ResourceGroup
    address_prefixes                = [var.Network.SubnetCidr]
}

data "azurerm_subnet" "appservicesubnet" {
    name = var.Network.AppServiceSubnetName
    resource_group_name = var.Network.Vnet.ResourceGroup
    virtual_network_name = var.Network.Vnet.Name
}

data "azurerm_subnet" "appservicesubnet_dr" {
    count = var.DrResource.ResourceCount
    name = var.Network_Dr.AppServiceSubnetName
    resource_group_name = var.Network_Dr.Vnet.ResourceGroup
    virtual_network_name = var.Network_Dr.Vnet.Name
}

resource "azurerm_subnet_route_table_association" "srt" {
    subnet_id                       = azurerm_subnet.snet.id
    route_table_id                  = data.azurerm_route_table.rt.id
}

resource "azurerm_network_security_group" "nsg" {
    name                            = "${azurerm_subnet.snet.name}-nsg"
    resource_group_name             = azurerm_resource_group.rg.name
    location						= local.tags.location
    tags                            = local.tags
}