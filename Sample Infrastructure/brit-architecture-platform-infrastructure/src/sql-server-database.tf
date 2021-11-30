data "azuread_group" "adgroup" {
  name                              = "${local.ad_group_name}"
}

resource "azurerm_sql_server" "sqlserver" {
  name                              = local.sql_server_name
  resource_group_name               = azurerm_resource_group.rg.name
  location                          = var.primary.azure_region
  version                           = "12.0"
  administrator_login               = var.admin_username
  administrator_login_password      = var.admin_password
  tags                              = local.tags
  identity {
        type = "SystemAssigned"
    }
  }

resource "azurerm_sql_firewall_rule" "sqlserver-fw-rule-1" {
  name                              = "BritCorpNetworkRule"
  resource_group_name               = azurerm_resource_group.rg.name
  server_name                       = azurerm_sql_server.sqlserver.name
  start_ip_address                  = "84.207.239.144"
  end_ip_address                    = "84.207.239.159"
}

resource "azurerm_sql_firewall_rule" "sqlserver-fw-rule-2" {
  name                              = "BritAzureVDIAndWVDIRule"
  resource_group_name               = azurerm_resource_group.rg.name
  server_name                       = azurerm_sql_server.sqlserver.name
  start_ip_address                  = "194.0.238.7"
  end_ip_address                    = "194.0.238.7"
}

resource "azurerm_sql_firewall_rule" "sqlserver-fw-rule-3" {
  name                              = "ZscalerRule"
  resource_group_name               = azurerm_resource_group.rg.name
  server_name                       = azurerm_sql_server.sqlserver.name
  start_ip_address                  = "165.225.80.0"
  end_ip_address                    = "165.225.80.255"
}

resource "azurerm_sql_firewall_rule" "sqlserver-fw-rule-4" {
  name                              = "ZscalerFailoverRule"
  resource_group_name               = azurerm_resource_group.rg.name
  server_name                       = azurerm_sql_server.sqlserver.name
  start_ip_address                  = "165.225.88.0"
  end_ip_address                    = "165.225.88.255"
}

resource "azurerm_sql_firewall_rule" "sqlserver-fw-rule-5" {
  name                              = "ZScaler II"
  resource_group_name               = azurerm_resource_group.rg.name
  server_name                       = azurerm_sql_server.sqlserver.name
  start_ip_address                  = "147.161.166.0"
  end_ip_address                    = "147.161.167.255"
}

resource "azurerm_sql_firewall_rule" "sqlserver-fw-rule-6" {
  name                              = "ZscalerUS"
  resource_group_name               = azurerm_resource_group.rg.name
  server_name                       = azurerm_sql_server.sqlserver.name
  start_ip_address                  = "168.62.109.126"
  end_ip_address                    = "168.62.109.126"
}

resource "azurerm_sql_firewall_rule" "sqlserver-fw-rule-7" {
  name                              = "Azure_FW_UKS"
  resource_group_name               = azurerm_resource_group.rg.name
  server_name                       = azurerm_sql_server.sqlserver.name
  start_ip_address                  = "40.81.145.128"
  end_ip_address                    = "40.81.145.128"
}

resource "azurerm_sql_firewall_rule" "sqlserver-fw-rule-8" {
  name                              = "Azure_FW_UKW"
  resource_group_name               = azurerm_resource_group.rg.name
  server_name                       = azurerm_sql_server.sqlserver.name
  start_ip_address                  = "40.81.125.132"
  end_ip_address                    = "40.81.125.132"
}

resource "azurerm_sql_active_directory_administrator" "sql-ad-admin" {
  server_name                       = azurerm_sql_server.sqlserver.name
  resource_group_name               = azurerm_resource_group.rg.name
  login                             = local.ad_group_name
  tenant_id                         = var.tenant_id
  object_id                         = data.azuread_group.adgroup.id
}

resource "azurerm_sql_database" "sqldb" {
  name                              = local.sql_svr_db_name
  resource_group_name               = azurerm_resource_group.rg.name
  location                          = var.primary.azure_region
  edition                           = "Standard"
  requested_service_objective_name  = "S2"
  create_mode                       = "Default"
  server_name                       = azurerm_sql_server.sqlserver.name
  depends_on                        = [azurerm_sql_server.sqlserver]
  tags                              = local.tags
}
