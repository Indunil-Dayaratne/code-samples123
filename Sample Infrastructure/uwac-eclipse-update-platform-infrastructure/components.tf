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
  tags     = "${local.tags}"
  depends_on = ["azurerm_resource_group.rg"]
}

resource "azurerm_storage_account" "funcstorage" {
  name                     = "${local.storage_account_name}"
  resource_group_name = "${local.resource_group_name}"
  location                 = "${var.azure_region}"
  tags     = "${local.tags}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on = ["azurerm_resource_group.rg"]
}

resource "azurerm_function_app" "eclipse-validator-func" {
  name                      = "${local.validator_function_name}"
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

resource "azurerm_function_app" "eclipse-mapper-func" {
  name                      = "${local.mapper_function_name}"
  location                  = "${var.azure_region}"
  resource_group_name       = "${local.resource_group_name}"
  app_service_plan_id       = "${local.app_service_plan_id}"
  storage_connection_string = "${azurerm_storage_account.funcstorage.primary_connection_string}"
  version = "~3"
  identity = [{ type = "SystemAssigned"}]
  https_only = "True"
  tags     = "${local.tags}"
  depends_on = ["azurerm_storage_account.funcstorage"]
  site_config = [{ always_on = "true" }]
  lifecycle {
    ignore_changes = ["app_settings"]
  }  
}

resource "azurerm_key_vault" "keyvault" {
  name                        = "${local.key_vault_name}"
  location                    = "${var.azure_region}"
  resource_group_name         = "${local.resource_group_name}"
  enabled_for_disk_encryption = true
  tenant_id                   = "${var.tenant_id}"
  depends_on = ["azurerm_resource_group.rg"]

  sku {
    name = "standard"
  }

  tags = "${local.tags}"
}
