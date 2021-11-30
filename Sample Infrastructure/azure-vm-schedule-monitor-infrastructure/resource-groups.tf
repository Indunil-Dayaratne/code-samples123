resource "azurerm_resource_group" "app-rg" {
  name     = "${local.resource_group_name}"
  location = "${var.azure_region}"
  tags     = "${local.tags}"
}