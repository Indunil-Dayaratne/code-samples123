// Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_group_name}"
  location = "${var.azure_region}"
  tags     = "${local.tags}"
}

resource "azurerm_application_insights" "appins" {
  name                =  "${local.app_insights_name}"
  location            = "West Europe"
  resource_group_name = "${local.resource_group_name}"
  application_type    = "Web"
  tags                = "${local.tags}"
  depends_on          = ["azurerm_resource_group.rg"]
}

resource "azurerm_storage_account" "funcstorage" {
  name                     = "${local.storage_account_name}"
  resource_group_name      = "${local.resource_group_name}"
  location                 = "${var.azure_region}"
  tags                     = "${local.tags}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on               = ["azurerm_resource_group.rg"]
}

resource "azurerm_function_app" "user-preference-service-func" {
  name                      = "${local.user_preference_service_function_name}"
  location                  = "${var.azure_region}"
  resource_group_name       = "${local.resource_group_name}"
  app_service_plan_id       = "${local.app_service_plan_id}"
  storage_connection_string = "${azurerm_storage_account.funcstorage.primary_connection_string}"
  version                   = "~2"
  identity                  = [{ type = "SystemAssigned"}]
  https_only                = "True"
  tags                      = "${local.tags}"
  depends_on                = ["azurerm_resource_group.rg", "azurerm_storage_account.funcstorage"]
}

resource "azurerm_sql_server" "sqlserver" {
  name                         = "${local.sql_svr_name}"
  resource_group_name          = "${local.resource_group_name}"
  location                     = "${var.azure_region}"
  version                      = "12.0"
  administrator_login          = "${var.admin_username}"
  administrator_login_password = "${var.admin_password}"
  tags                         = "${local.tags}"
  depends_on                   = ["azurerm_resource_group.rg"]
}

resource "azurerm_sql_firewall_rule" "sqlserver-fw-rule" {
  name                = "BritGuestProxyRule"
  resource_group_name = "${local.resource_group_name}"
  server_name         = "${azurerm_sql_server.sqlserver.name}"
  start_ip_address    = "165.225.80.233"
  end_ip_address      = "165.225.80.233"
}

resource "azurerm_sql_firewall_rule" "sqlserver-fw-rule-azure-services" {
  name                = "AzureResourcesRule"
  resource_group_name = "${local.resource_group_name}"
  server_name         = "${azurerm_sql_server.sqlserver.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_sql_database" "sqldb" {
  name                = "${local.sql_svr_db_name}"
  resource_group_name = "${local.resource_group_name}"
  location            = "${var.azure_region}"
  edition             = "Basic"
  create_mode         = "Default"
  server_name         = "${azurerm_sql_server.sqlserver.name}"
  depends_on          = ["azurerm_sql_server.sqlserver"]
  tags                = "${local.tags}"
}

resource "azurerm_key_vault" "keyvault" {
  name                        = "${local.key_vault_name}"
  location                    = "${var.azure_region}"
  resource_group_name         = "${local.resource_group_name}"
  enabled_for_disk_encryption = true
  tenant_id                   = "${var.tenant_id}"
  depends_on                   = ["azurerm_resource_group.rg"]
  sku {
    name = "standard"
  }

   access_policy {
    tenant_id = "${var.tenant_id}"
    object_id = "${var.spn_object_id}"
    # application_id = "${var.spn_app_id}"

    secret_permissions = [
      "get",
      "list",
      "set"
    ]
  }
  lifecycle {
    ignore_changes = [
      "access_policy"
    ]
  }
  
  tags = "${local.tags}"
}

resource "azuread_group" "adgroup" {
  name = "${local.ad_group_name}"
}

resource "azuread_group" "adgroup_read" {
  name = "${local.ad_read_group_name}"
}

resource "azuread_group" "adgroup_write" {
  name = "${local.ad_write_group_name}"
}

resource "azuread_group" "adgroup_admin" {
  name = "${local.ad_admin_group_name}"
}

data "azuread_application" "beaskv" {
  name = "${local.beas_app_name}"
}

resource "azurerm_key_vault_secret" "beas-client-key" {
  name                        = "beas-client-id"
  value                       = "${data.azuread_application.beaskv.application_id}"
  key_vault_id                = "${azurerm_key_vault.keyvault.id}"
  depends_on                  = ["azurerm_resource_group.rg", "azurerm_key_vault.keyvault"]
}
