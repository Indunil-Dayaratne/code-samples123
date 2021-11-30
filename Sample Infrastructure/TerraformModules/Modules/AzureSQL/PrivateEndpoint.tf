resource "azurerm_private_endpoint" "pep" {
    count               = var.PrivateEndpoint == true ? 1 : 0

    name                = replace(local.basename, "##", "pep")
    resource_group_name = var.ResourceGroup
    location            = var.Location
    subnet_id           = data.azurerm_subnet.pep-subnet[0].id
    tags                = var.Tags

    private_service_connection {
        name                            = replace(local.basename, "##", "pep")
        private_connection_resource_id  = azurerm_mssql_server.azsqlserver-primary.id
        subresource_names               = ["sqlServer"]
        is_manual_connection            = false
    }
}

data "azurerm_virtual_network" "pep-vnet" {
    count               = var.PrivateEndpoint == true ? 1 : 0

    name                = var.VirtualNetworkName
    resource_group_name = var.VirtualNetworkRGName
}

data "azurerm_subnet" "pep-subnet" {
    count                = var.PrivateEndpoint == true ? 1 : 0

    name                 = var.SubnetName
    virtual_network_name = data.azurerm_virtual_network.pep-vnet[0].name
    resource_group_name  = data.azurerm_virtual_network.pep-vnet[0].resource_group_name
}