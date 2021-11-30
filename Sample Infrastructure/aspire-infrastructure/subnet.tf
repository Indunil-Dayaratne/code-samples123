data "azurerm_virtual_network" "platform" {
    name = "${var.aspire_vnet_name}"
    resource_group_name = "${var.aspire_vnet_resource_group_name}"
}

resource "azurerm_subnet" "current" {
    address_prefix = "${var.aspire_subnet_cidr}"
    name = "aspire-sn-${terraform.workspace}"
    resource_group_name = "${data.azurerm_virtual_network.platform.resource_group_name}"
    virtual_network_name = "${data.azurerm_virtual_network.platform.name}"
}

resource "azurerm_subnet_network_security_group_association" "nsg" {
    network_security_group_id = "${azurerm_network_security_group.aspire.id}"
    subnet_id = "${azurerm_subnet.current.id}"
    
    lifecycle {
        ignore_changes = ["network_security_group_id", "subnet_id"]
    }
}