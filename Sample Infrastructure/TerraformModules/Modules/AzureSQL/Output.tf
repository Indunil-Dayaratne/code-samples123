output "SQLServerID" {
  value = [azurerm_mssql_server.azsqlserver-primary.id, var.FailoverGroup == true ? azurerm_mssql_server.azsqlserver-secondary[0].id : null]
}
output "SQLServerName" {
	value = [azurerm_mssql_server.azsqlserver-primary.name, var.FailoverGroup == true ? azurerm_mssql_server.azsqlserver-secondary[0].name : null]
}

output "AuditAccountID" {
  value = var.AuditAccount == null ? azurerm_storage_account.storageaccount[0].id : data.azurerm_storage_account.auditstorage[0].id
}

output "AuditAccountName" {
  value = var.AuditAccount == null ? azurerm_storage_account.storageaccount[0].name : data.azurerm_storage_account.auditstorage[0].name
}

output "PrivateEndpointIP" {
  value = var.PrivateEndpoint == true ? azurerm_private_endpoint.pep[0].private_service_connection[0].private_ip_address : null
}

output "FailoverGroupListener-ReadWrite" {
  value = var.FailoverGroup == true ? "${azurerm_sql_failover_group.fog[0].name}.database.windows.net" : null
}

output "FailoverGroupListener-ReadOnly" {
  value = var.FailoverGroup == true ? "${azurerm_sql_failover_group.fog[0].name}.secondary.database.windows.net" : null
}