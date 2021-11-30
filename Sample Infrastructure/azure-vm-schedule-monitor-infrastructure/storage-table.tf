resource "azurerm_storage_account" "storage" {
  name                     = "${lookup(local.tags,"storage")}"
  resource_group_name      = "${azurerm_resource_group.app-rg.name}"
  location                 = "${azurerm_resource_group.app-rg.location}"
  account_tier             = "${var.storage_account_tier}"
  account_replication_type = "${var.storage_account_replication_type}"

  tags                     = "${local.tags}" 
}

resource "azurerm_storage_table" "storagetable" {
  name                 = "${lookup(local.tags,"tablestore")}"
  resource_group_name  = "${azurerm_resource_group.app-rg.name}"
  storage_account_name = "${azurerm_storage_account.storage.name}"
}