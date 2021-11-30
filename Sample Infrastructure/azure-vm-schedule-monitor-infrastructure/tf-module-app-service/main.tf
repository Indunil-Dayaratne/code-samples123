resource "azurerm_app_service_plan" "default" {
  name                      = "${var.resource_prefix}-appserviceplan-${var.azure_short_region}-${var.environment}"
  location                  = "${var.resource_group_location}"
  resource_group_name       = "${var.resource_group_name}"
  kind                      = "${var.app_service_plan_kind}"

  sku {
    tier     = "${var.app_service_plan_sku_tier}"
    size     = "${var.app_service_plan_sku_size}"
    capacity = "${var.app_service_plan_sku_capacity}"
  }

  properties {
    reserved = "${var.app_service_plan_reserved}"
  }

  tags = "${var.tags}"
}

resource "azurerm_app_service" "default" {
  name                    = "${var.resource_prefix}-appservice-${var.azure_short_region}-${var.environment}"
  location                = "${var.resource_group_location}"
  resource_group_name     = "${var.resource_group_name}"
  app_service_plan_id     = "${azurerm_app_service_plan.default.id}"
  client_affinity_enabled = "${var.app_service_client_affinity_enabled}"
  enabled                 = "${var.app_service_enabled}"

  site_config             = ["${var.app_service_site_config}"]

  tags = "${var.tags}"
}
