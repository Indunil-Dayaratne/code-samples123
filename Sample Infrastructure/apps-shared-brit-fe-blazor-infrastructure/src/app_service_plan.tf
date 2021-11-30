resource "azurerm_app_service_plan" "appsp" {
  count               = var.enabled == "true" ? 1 : 0
  name                = "${local.appsp_name}-${var.azure_short_region}-${terraform.workspace}"
  location            = azurerm_resource_group.rg[0].location
  resource_group_name = azurerm_resource_group.rg[0].name
  kind                = var.appsp_kind

  sku {
    tier = var.appsp_tier
    size = var.appsp_size
  }

  tags = local.tags
  depends_on = [
    azurerm_resource_group.rg[0]
  ]
}

resource "azurerm_app_service_plan" "appsp_dr" {
  count               = var.enabled == "true" && var.dr_enabled == "true" ? 1 : 0
  name                = "${local.appsp_name}-${var.azure_short_region_dr}-${terraform.workspace}"
  location            = azurerm_resource_group.rg_dr[0].location
  resource_group_name = azurerm_resource_group.rg_dr[0].name
  kind                = var.appsp_kind

  sku {
    tier = var.appsp_tier
    size = var.appsp_size
  }

  tags = local.tags_dr
  depends_on = [
    azurerm_resource_group.rg_dr[0]
  ]
}