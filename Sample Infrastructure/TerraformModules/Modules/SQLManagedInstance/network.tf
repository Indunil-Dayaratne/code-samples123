data "azurerm_virtual_network" "SQLMI" {
    name                    = var.vnetName
    resource_group_name     = var.vnetResourceGroup
}

resource "azurerm_subnet" "snet" {
    name                    = "${var.Project}-sqlmi-snet-${var.Environment}"
    resource_group_name     = var.vnetResourceGroup
    virtual_network_name    = var.vnetName
    address_prefixes        = [var.SubnetRange]

    delegation {
        name = "delegation"

        service_delegation {
            name    = "Microsoft.Sql/managedInstances"
            actions = [
                "Microsoft.Network/virtualNetworks/subnets/join/action",
                "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
                "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
            ]
        }
    }
}

resource "azurerm_subnet_network_security_group_association" "sqlmi_snsg" {
    subnet_id                   = azurerm_subnet.snet.id
    network_security_group_id   = azurerm_network_security_group.SQLMI_nsg.id
}



data "azurerm_route_table" "rt" {
    name                    = var.routeTable
    resource_group_name     = var.routeTableRG
}

resource "azurerm_route" "r" {
    name                    = "${var.Project}-snet-vnetlocal"
    resource_group_name     = var.routeTableRG
    route_table_name        = var.routeTable
    address_prefix          = var.SubnetRange
    next_hop_type           = "vnetlocal"
}

resource "azurerm_subnet_route_table_association" "sqlmi_srt" {
    subnet_id                       = azurerm_subnet.snet.id
    route_table_id                  = data.azurerm_route_table.rt.id
}
