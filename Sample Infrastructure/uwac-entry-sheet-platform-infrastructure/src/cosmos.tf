data "azurerm_cosmosdb_account" "cosmosdb" {
  name                        = var.cosmos.account_name
  resource_group_name         = var.cosmos.resource_group
}

# we might need only one of the containers if the data is always retrived from bricache
# set Indexing_policy as required as by default cosmos with index on everything and use up lots of ru's
resource "azurerm_cosmosdb_sql_container" "entry_sheet" {
  name                = "entry-sheet-eclipse-${terraform.workspace}"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb.name
  database_name       = var.cosmos.db_name
  partition_key_path  = "/britPolicyId"
}

resource "azurerm_cosmosdb_sql_container" "entry_sheet_history" {
  name                = "entry-sheet-eclipse-history-${terraform.workspace}"
  resource_group_name = data.azurerm_cosmosdb_account.cosmosdb.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.cosmosdb.name
  database_name       = var.cosmos.db_name
  partition_key_path  = "/britPolicyId"
}