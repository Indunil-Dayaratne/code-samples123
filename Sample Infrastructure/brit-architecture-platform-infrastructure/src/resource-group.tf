resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.primary.azure_region
  tags     = local.tags
}

