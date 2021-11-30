resource "random_password" "sqlserver-primary" {
  length      = 30
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
}

resource "random_password" "sqlserver-secondary" {
  count       = var.FailoverGroup == true ? 1 : 0

  length      = 30
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
}

data "azurerm_key_vault" "kv" {
  name                = var.KeyVault.Name
  resource_group_name = var.KeyVault.Group
}

resource "azurerm_key_vault_secret" "sqlserver-primary" {
  name          = azurerm_mssql_server.azsqlserver-primary.name
  key_vault_id  = data.azurerm_key_vault.kv.id
  value         = random_password.sqlserver-primary.result
  tags          = var.Tags
}

resource "azurerm_key_vault_secret" "sqlserver-secondary" {
  count         = var.FailoverGroup == true ? 1 : 0

  name          = azurerm_mssql_server.azsqlserver-secondary[0].name
  key_vault_id  = data.azurerm_key_vault.kv.id
  value         = random_password.sqlserver-secondary[0].result
  tags          = var.Tags
}