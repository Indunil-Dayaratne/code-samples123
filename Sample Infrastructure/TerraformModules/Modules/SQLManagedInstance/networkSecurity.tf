resource "azurerm_network_security_group" "SQLMI_nsg" {
    name                                = "${var.Project}-sqlmi-nsg-${var.Environment}"
    resource_group_name                 = var.ResourceGroup
    location                            = var.location
    tags                                = var.Tags

    lifecycle {
        ignore_changes                  = [security_rule]
    }

    dynamic "security_rule" {
        for_each                        = local.nsg_rules
        iterator                        = rule
        content {
            name                        = rule.key
            description                 = rule.value["description"]
            protocol                    = rule.value["protocol"]
            source_port_range           = length(rule.value["source"]["range"]) == 0 ? rule.value["source"]["port"] : null
            source_port_ranges          = length(rule.value["source"]["range"]) > 0 ? rule.value["source"]["range"] : null
            destination_port_range      = length(rule.value["destination"]["range"]) == 0 ? rule.value["destination"]["port"] : null
            destination_port_ranges     = length(rule.value["destination"]["range"]) > 0 ? rule.value["destination"]["range"] : null
            source_address_prefix       = rule.value["source"]["prefix"]
            destination_address_prefix  = rule.value["destination"]["prefix"]
            access                      = rule.value["access"]
            priority                    = rule.value["priority"]
            direction                   = rule.value["direction"]
        }
    }
}
