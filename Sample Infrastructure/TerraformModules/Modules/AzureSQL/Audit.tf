resource "azurerm_storage_account" "storageaccount" {
  count                    = var.AuditStorage == true && var.AuditAccount == null ? 1 : 0

  name                     = replace(local.shortname, "##", "sa")
  resource_group_name      = var.ResourceGroup
  location                 = var.Location
  account_tier             = var.AccountTier
  account_replication_type = var.StorageReplication

  tags                     = var.Tags
}

data "azurerm_storage_account" "auditstorage" {
  count                    = var.AuditStorage == true && var.AuditAccount != null ? 1 : 0

  name                     = var.AuditAccount
  resource_group_name      = var.AuditAccountRGName
}

resource "azurerm_mssql_server_extended_auditing_policy" "eap-primary" {
  count                       = var.AuditStorage == true ? 1 : 0

  server_id                   = azurerm_mssql_server.azsqlserver-primary.id
  storage_endpoint            = var.AuditAccount == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : data.azurerm_storage_account.auditstorage[0].primary_blob_endpoint
  storage_account_access_key  = var.AuditAccount == null ? azurerm_storage_account.storageaccount[0].primary_access_key : data.azurerm_storage_account.auditstorage[0].primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days           = var.LogRetentionInDays
}

resource "azurerm_mssql_server_extended_auditing_policy" "eap-secondary" {
  count                       = var.AuditStorage == true && var.FailoverGroup == true ? 1 : 0

  server_id                               = azurerm_mssql_server.azsqlserver-secondary[0].id
  storage_endpoint                        = var.AuditAccount == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : data.azurerm_storage_account.auditstorage[0].primary_blob_endpoint
  storage_account_access_key              = var.AuditAccount == null ? azurerm_storage_account.storageaccount[0].primary_access_key : data.azurerm_storage_account.auditstorage[0].primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.LogRetentionInDays
}