resource "azurerm_resource_group" "aspire_rg" {
  location = "${var.azure_region}"
  name = "aspire-rg-${var.azure_short_region}-${terraform.workspace}"

  tags = "${local.tags}"
}