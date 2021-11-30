data "azurerm_subnet" "appservicesubnet" {
    name = var.Network.AppServiceSubnetName
    resource_group_name = var.Network.Vnet.ResourceGroup
    virtual_network_name = var.Network.Vnet.Name
}

data "azurerm_subnet" "appservicesubnet_dr" {
    name = var.Network_Dr.AppServiceSubnetName
    resource_group_name = var.Network_Dr.Vnet.ResourceGroup
    virtual_network_name = var.Network_Dr.Vnet.Name
}