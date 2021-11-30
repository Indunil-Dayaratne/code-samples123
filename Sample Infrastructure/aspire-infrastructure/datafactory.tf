resource "azurerm_data_factory" "current" {
    name = "aspire-adf-${var.azure_short_region}-${terraform.workspace}"
    resource_group_name = "${azurerm_resource_group.aspire_rg.name}"
    location = "${azurerm_resource_group.aspire_rg.location}"
    
    identity {
        type = "SystemAssigned"
    }
    
    tags = "${local.tags}"
}

resource "azurerm_role_assignment" "contributor_role_for_adf" {
    principal_id = "${azurerm_data_factory.current.identity.0.principal_id}"
    scope = "${azurerm_data_factory.current.id}"
    role_definition_name = "Contributor"
}

resource "azurerm_data_factory_integration_runtime_managed" "current" {
    name = "aspire-adf-ssisruntime-${var.azure_short_region}-${terraform.workspace}"
    data_factory_name = "${azurerm_data_factory.current.name}"
    resource_group_name = "${azurerm_data_factory.current.resource_group_name}"
    location = "${azurerm_data_factory.current.location}"
    node_size = "Standard_D2_v3"
    license_type = "BasePrice"
    edition = "Standard"
    
    catalog_info {
        server_endpoint = "${azurerm_sql_failover_group.failover.name}.database.windows.net"
        administrator_login = "${azurerm_sql_server.aspiresvr.*.administrator_login[0]}"
        administrator_password = "${azurerm_sql_server.aspiresvr.*.administrator_login_password[0]}"
        pricing_tier = "Standard"
    }
    
    vnet_integration {
        vnet_id = "${data.azurerm_virtual_network.platform.id}"
        subnet_name = "${azurerm_subnet.current.name}"
    }
    
    lifecycle {
        ignore_changes = ["catalog_info.0.pricing_tier"]
    }
}