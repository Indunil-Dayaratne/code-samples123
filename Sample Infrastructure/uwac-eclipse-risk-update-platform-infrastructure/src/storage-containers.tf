data "azurerm_storage_account" "esbstorage" {
  name                     = var.esb.storage_account
  resource_group_name      = var.esb.resource_group
}

resource "azurerm_storage_container" "eclipse_risk_update_in_cont" { 
  name                  = "eclipse-risk-update-in"  
  storage_account_name  = data.azurerm_storage_account.esbstorage.name  
  container_access_type = "private"  
}  

resource "azurerm_storage_container" "eclipse_risk_in_cont" { 
  name                  = "eclipse-risk-in"  
  storage_account_name  = data.azurerm_storage_account.esbstorage.name 
  container_access_type = "private"  
} 
