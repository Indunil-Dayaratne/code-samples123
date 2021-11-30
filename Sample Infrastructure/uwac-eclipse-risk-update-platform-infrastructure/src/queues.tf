data "azurerm_servicebus_namespace" "esb_svcbus" {
  name                = var.esb.service_bus
  resource_group_name = var.esb.resource_group
}

resource "azurerm_servicebus_queue" "eclipse_risk_update_in_queue" {
  name                = "eclipse-risk-update-in"
  resource_group_name = var.esb.resource_group
  namespace_name      = var.esb.service_bus
  enable_partitioning = true
}

resource "azurerm_servicebus_queue" "eclipse_risk_in_queue" {
  name                = "eclipse-risk-in"
  resource_group_name = var.esb.resource_group
  namespace_name      = var.esb.service_bus
  enable_partitioning = true
}