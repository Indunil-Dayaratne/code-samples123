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
  account_kind             = "StorageV2"
  account_replication_type = "ZRS"
  depends_on               = ["azurerm_resource_group.rg"]
}

resource "azurerm_storage_container" "storagecont" { 
  name                  = "${local.storage_container_name}"  
  storage_account_name  = "${azurerm_storage_account.funcstorage.name}"  
  container_access_type = "private"  
  depends_on = ["azurerm_storage_account.funcstorage"]
}  

resource "azurerm_function_app" "media-persistence-func" {
  name                      = "${local.media_persistence_function_name}"
  location                  = "${var.azure_region}"
  resource_group_name       = "${local.resource_group_name}"
  app_service_plan_id       = "${var.app_service_plan_id}"
  storage_connection_string = "${azurerm_storage_account.funcstorage.primary_connection_string}"
  version                   = "~2"
  identity                  = [{ type = "SystemAssigned"}]
  site_config               = [{ always_on = "true" }] 
  https_only                = "True"
  tags                      = "${local.tags}"
  depends_on                = ["azurerm_resource_group.rg", "azurerm_storage_account.funcstorage"]
}

resource "azurerm_key_vault" "keyvault" {
  name                        = "${local.key_vault_name}"
  location                    = "${var.azure_region}"
  resource_group_name         = "${local.resource_group_name}"
  enabled_for_disk_encryption = true
  tenant_id                   = "${var.tenant_id}"
  depends_on                  = ["azurerm_resource_group.rg"]

  sku {
    name = "standard"
  }

   access_policy {
    tenant_id = "${var.tenant_id}"
    object_id = "${var.spn_object_id}"
    application_id = "${var.spn_app_id}"

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

data "azurerm_cosmosdb_account" "cosmosdb" {
  name                        = "${var.cosmosdb_account_name}"
  resource_group_name         = "${var.common_shared_services_resource_group_name}"
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

resource "azurerm_key_vault_secret" "cosmos-account-key" {
  name                        = "cosmos-account-primary-key"
  value                       = "${data.azurerm_cosmosdb_account.cosmosdb.primary_master_key}"
  key_vault_id                = "${azurerm_key_vault.keyvault.id}"
  depends_on                  = ["azurerm_resource_group.rg", "azurerm_key_vault.keyvault"]
}

resource "azurerm_key_vault_secret" "storage-connection-key" {
  name                        = "storage-conection-string"
  value                       = "${azurerm_storage_account.funcstorage.primary_connection_string}"
  key_vault_id                = "${azurerm_key_vault.keyvault.id}"
  depends_on                  = ["azurerm_resource_group.rg", "azurerm_key_vault.keyvault", "azurerm_storage_account.funcstorage"]
}

resource "azurerm_cosmosdb_sql_container" "images" {
  name                = "media-container-${terraform.workspace}"
  resource_group_name = "${var.common_shared_services_resource_group_name}"
  account_name        = "${data.azurerm_cosmosdb_account.cosmosdb.name}"
  database_name       = "${var.cosmosdb_database_name}"
  partition_key_path  = "/id"

  unique_key {
    paths = ["/idlong", "/idshort"]
  }
}
