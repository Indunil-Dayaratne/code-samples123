resource "azurerm_storage_account" "store" {
  name                     = "${var.storage_acc_name}"
  resource_group_name      = "${azurerm_resource_group.app-rg.name}"
  location                 = "${azurerm_resource_group.app-rg.location}"
  account_tier             = "${var.storage_account_tier}"
  account_replication_type = "${var.storage_account_rep_type}"
  account_kind             = "${var.storage_account_kind}"

  tags                     = "${local.tags}"
}

resource "azurerm_storage_container" "store" {
  name                  = "${var.storage_container_name}"
  resource_group_name   = "${azurerm_resource_group.app-rg.name}"
  storage_account_name  = "${azurerm_storage_account.store.name}"
  container_access_type = "${var.storage_container_type}"
}
