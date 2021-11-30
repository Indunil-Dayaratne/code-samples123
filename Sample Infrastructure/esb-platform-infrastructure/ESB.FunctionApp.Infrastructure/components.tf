
resource "azurerm_application_insights" "appins" {
  name                =  "${local.app_insights_name}"
  location            = "West Europe"
  resource_group_name = "${local.resource_group_name}"
  application_type    = "Web"
  tags     = "${local.tags}"
}

resource "azurerm_storage_account" "funcstorage" {
  name                     = "${local.storage_account_name}"
  resource_group_name = "${local.resource_group_name}"
  location                 = "${var.azure_region}"
  tags     = "${local.tags}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_function_app" "notification-func" {
  name                      = "${local.notification_function_name}"
  location                  = "${var.azure_region}"
  resource_group_name       = "${local.resource_group_name}"
  app_service_plan_id       = "${local.app_service_plan_id}"
  storage_connection_string = "${azurerm_storage_account.funcstorage.primary_connection_string}"
  version = "~2"
  identity = [{ type = "SystemAssigned"}]
  https_only = "True"
  tags     = "${local.tags}"
  depends_on = ["azurerm_storage_account.funcstorage"]
  site_config = [{ always_on = "true" }]
  lifecycle {
    ignore_changes = ["app_settings"]
  }  
}

resource "azurerm_signalr_service" "signalr" {
  name                = "${local.signalr_name}"
  location            = "westeurope"
  resource_group_name = "${local.resource_group_name}"
  tags     = "${local.tags}"

  sku {
    name     = "Standard_S1"
    capacity = 1
  }
}