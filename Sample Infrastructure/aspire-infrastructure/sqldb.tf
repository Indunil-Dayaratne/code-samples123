locals {
    sqlserver_name = "aspire-sqlsvr-${var.azure_short_region}-${terraform.workspace}"
    dr_azure_short_region = "ukw"
    dr_azure_region = "UK West"
    dr_sqlserver_name = "aspire-sqlsvr-${local.dr_azure_short_region}-${terraform.workspace}dr"
}

resource "azurerm_resource_group" "aspire_rg_dr" {
    location = "UK West"
    name = "aspire-rg-${local.dr_azure_short_region}-${terraform.workspace}dr"
    
    tags = {
        project = "${local.tags["project"]}"
        environment = "${terraform.workspace}"
        app = "${local.tags["app"]}"
        contact = "${local.tags["contact"]}"
        contact_details = "${local.tags["contact_details"]}"
        costcentre = "${local.tags["costcentre"]}"
        description = "${local.tags["description"]}"
        location = "${local.dr_azure_region}"
        terraformed = "yes"
    }
}

data "azurerm_sql_database" "aspire" {
    name = "Aspire"
    resource_group_name = "${azurerm_sql_server.aspiresvr.*.resource_group_name[0]}"
    server_name = "${azurerm_sql_server.aspiresvr.*.name[0]}"
}

data "azurerm_sql_database" "ssisdb" {
    name = "SSISDB"
    resource_group_name = "${azurerm_sql_server.aspiresvr.*.resource_group_name[0]}"
    server_name = "${azurerm_sql_server.aspiresvr.*.name[0]}"
}

resource "azurerm_sql_failover_group" "failover" {
    name = "aspire-sqlsvr-fog-${terraform.workspace}"
    resource_group_name = "${azurerm_sql_server.aspiresvr.*.resource_group_name[0]}"
    server_name = "${azurerm_sql_server.aspiresvr.*.name[0]}"

    databases = ["${data.azurerm_sql_database.aspire.id}", "${data.azurerm_sql_database.ssisdb.id}"]

    partner_servers {
        id = "${azurerm_sql_server.aspiresvr.*.id[1]}"
    }

    read_write_endpoint_failover_policy {
        mode = "Automatic"
        grace_minutes = 60
    }

    tags = "${local.tags}"
}

resource "azurerm_sql_server" "aspiresvr" {
    name                         = "${count.index == 0 ? local.sqlserver_name : local.dr_sqlserver_name}"
    resource_group_name          = "${count.index == 0 ? azurerm_resource_group.aspire_rg.name : azurerm_resource_group.aspire_rg_dr.name}"
    location                     = "${count.index == 0 ? azurerm_resource_group.aspire_rg.location : azurerm_resource_group.aspire_rg_dr.location}"
    version                      = "12.0"
    administrator_login          = "cloudadmin"
    administrator_login_password = "${var.aspire_db_server_admin_password}"

    tags = {
        project = "${local.tags["project"]}"
        environment = "${terraform.workspace}"
        app = "${local.tags["app"]}"
        contact = "${local.tags["contact"]}"
        contact_details = "${local.tags["contact_details"]}"
        costcentre = "${local.tags["costcentre"]}"
        description = "${local.tags["description"]}"
        location = "${count.index == 0 ? local.tags["location"] : local.dr_azure_region}"
        terraformed = "yes"
    }

    count = 2
}

resource "azurerm_sql_active_directory_administrator" "sec_azurecloud_ops" {
    login = "sec_azurecloud_ops"
    object_id = "a6efc439-204e-409c-8844-dde138bfca5f" //Object Id of SEC-AzureCloud-Ops AAD group
    server_name = "${azurerm_sql_server.aspiresvr.*.name[count.index]}"
    resource_group_name = "${azurerm_sql_server.aspiresvr.*.resource_group_name[count.index]}"
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"

    count = 2
}

resource "azurerm_sql_firewall_rule" "britvdi" {
    name = "Brit Azure VDI"
    start_ip_address = "194.0.238.7"
    end_ip_address = "194.0.238.7"
    server_name = "${azurerm_sql_server.aspiresvr.*.name[count.index]}"
    resource_group_name = "${azurerm_sql_server.aspiresvr.*.resource_group_name[count.index]}"

    count = 2
}

resource "azurerm_sql_firewall_rule" "britcorp" {
    name = "Brit Corp"
    start_ip_address = "84.207.239.144"
    end_ip_address = "84.207.239.159"
    server_name = "${azurerm_sql_server.aspiresvr.*.name[count.index]}"
    resource_group_name = "${azurerm_sql_server.aspiresvr.*.resource_group_name[count.index]}"

    count = 2
}

resource "azurerm_sql_firewall_rule" "zscaler" {
    name = "Zscaler"
    start_ip_address = "165.225.80.0"
    end_ip_address = "165.225.80.255"
    server_name = "${azurerm_sql_server.aspiresvr.*.name[count.index]}"
    resource_group_name = "${azurerm_sql_server.aspiresvr.*.resource_group_name[count.index]}"

    count = 2
}

resource "azurerm_sql_firewall_rule" "zscaler_failover" {
    name = "Zscaler Failover"
    start_ip_address = "165.225.88.0"
    end_ip_address = "165.225.88.255"
    server_name = "${azurerm_sql_server.aspiresvr.*.name[count.index]}"
    resource_group_name = "${azurerm_sql_server.aspiresvr.*.resource_group_name[count.index]}"

    count = 2
}

resource "azurerm_sql_firewall_rule" "azureinternal" {
    name = "Azure Internal"
    start_ip_address = "0.0.0.0"
    end_ip_address = "0.0.0.0"
    server_name = "${azurerm_sql_server.aspiresvr.*.name[count.index]}"
    resource_group_name = "${azurerm_sql_server.aspiresvr.*.resource_group_name[count.index]}"

    count = 2
}