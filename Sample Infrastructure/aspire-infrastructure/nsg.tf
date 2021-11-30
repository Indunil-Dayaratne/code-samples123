resource "azurerm_network_security_group" "aspire" {
    location = "${data.azurerm_virtual_network.platform.location}"
    name = "aspire-nsg-${terraform.workspace}"
    resource_group_name = "${azurerm_resource_group.aspire_rg.name}"

    tags = "${local.tags}"
}

resource "azurerm_network_security_rule" "BatchNodeManagement" {
    access = "Allow"
    direction = "Inbound"
    name = "BatchNodeManagement"
    priority = 100
    protocol = "TCP"
    source_address_prefix = "BatchNodeManagement"
    source_port_range = "*"
    destination_address_prefix = "VirtualNetwork"
    destination_port_range = "29876-29877"
    network_security_group_name = "${azurerm_network_security_group.aspire.name}"
    resource_group_name = "${azurerm_network_security_group.aspire.resource_group_name}"
}

resource "azurerm_network_security_rule" "443toAzureCloud" {
    access = "Allow"
    direction = "Outbound"
    name = "443"
    priority = 101
    protocol = "TCP"
    source_address_prefix = "VirtualNetwork"
    source_port_range = "*"
    destination_address_prefix = "AzureCloud"
    destination_port_range = "443"
    network_security_group_name = "${azurerm_network_security_group.aspire.name}"
    resource_group_name = "${azurerm_network_security_group.aspire.resource_group_name}"
}

resource "azurerm_network_security_rule" "80" {
    access = "Allow"
    direction = "Outbound"
    name = "80"
    priority = 102
    protocol = "TCP"
    source_address_prefix = "VirtualNetwork"
    source_port_range = "*"
    destination_address_prefix = "Internet"
    destination_port_range = "80"
    network_security_group_name = "${azurerm_network_security_group.aspire.name}"
    resource_group_name = "${azurerm_network_security_group.aspire.resource_group_name}"
}

resource "azurerm_network_security_rule" "Sql" {
    access = "Allow"
    direction = "Outbound"
    name = "Sql"
    priority = 103
    protocol = "TCP"
    source_address_prefix = "VirtualNetwork"
    source_port_range = "*"
    destination_address_prefix = "Sql"
    destination_port_ranges = ["1433", "11000-11999"]
    network_security_group_name = "${azurerm_network_security_group.aspire.name}"
    resource_group_name = "${azurerm_network_security_group.aspire.resource_group_name}"
}