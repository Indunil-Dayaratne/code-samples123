resource "azurerm_network_interface" "nic" {
    name                                = length(var.VmNames) > 0 ? "${var.VmNames[count.index]}-nic" : "${var.Project}-vm-${count.index <= 9 ? "0${count.index + 1}" : count.index + 1}-${var.Environment}-nic"
    location                            = var.Location
    resource_group_name                 = var.ResourceGroup
    tags                                = var.Tags

    ip_configuration {
        name                            = "private"
        subnet_id                       = var.Subnet
        private_ip_address_allocation   = "Dynamic"
    }

    count                               = length(var.VmNames) > 0 ? length(var.VmNames) : var.VmCount
}

resource "azurerm_network_interface_security_group_association" "nicNsgLink" {
    network_interface_id                = azurerm_network_interface.nic.*.id[count.index]
    network_security_group_id           = var.Nsg

    count                               = length(var.VmNames) > 0 ? length(var.VmNames) : var.VmCount
}
