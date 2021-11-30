resource "azurerm_mssql_firewall_rule" "fwrule-primary" {
    for_each         = local.FirewallRules

    name             = each.key
    server_id        = azurerm_mssql_server.azsqlserver-primary.id
    start_ip_address = each.value.start_ip
    end_ip_address   = each.value.end_ip
}

resource "azurerm_mssql_firewall_rule" "fwrule-secondary" {
    for_each         = var.FailoverGroup == true ? local.FirewallRules : {}

    name             = each.key
    server_id        = var.FailoverGroup == true ? azurerm_mssql_server.azsqlserver-secondary[0].id : null
    start_ip_address = each.value.start_ip
    end_ip_address   = each.value.end_ip
}