resource "azurerm_storage_account" "funcstorage" {
  name                     = "${local.storage_account_name}${var.primary.azure_short_region}${terraform.workspace}"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  tags                     = local.tags
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "ZRS"
}

resource "azurerm_storage_account" "funcstorage_dr" {
  name                     = "${local.storage_account_name}${var.azure_short_region_dr}${terraform.workspace}"
  resource_group_name      = azurerm_resource_group.rg_dr.name
  location                 = azurerm_resource_group.rg_dr.location
  tags                     = local.tags_dr
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "ZRS"
}