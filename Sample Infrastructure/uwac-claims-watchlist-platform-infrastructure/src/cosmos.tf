data "azurerm_cosmosdb_account" "cosmosdb" {
  name                        = var.cosmos.account_name
  resource_group_name         = var.cosmos.resource_group
}

resource "azurerm_cosmosdb_sql_container" "claims_watchlist" {
  name                = "claims-watchlist-${terraform.workspace}"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb.name
  database_name       = var.cosmos.db_name
  partition_key_path  = "/id"
}