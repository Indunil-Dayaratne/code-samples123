resource "azurerm_servicebus_queue" "sdcauditinqueue" {
  name                = "sdc-audit-in"
  resource_group_name = "${local.resource_group_name}"
  namespace_name      = "${local.namespace_name}"
}

resource "azurerm_servicebus_queue_authorization_rule" "sdcauditinlistenrule" {
  name                = "listen"
  namespace_name      = "${local.namespace_name}"
  queue_name          = "sdc-audit-in"
  resource_group_name = "${local.resource_group_name}"
  listen = true
  send   = false
  manage = false
}

resource "azurerm_servicebus_queue_authorization_rule" "sdcauditinsendrule" {
  name                = "send"
  namespace_name      = "${local.namespace_name}"
  queue_name          = "sdc-audit-in"
  resource_group_name = "${local.resource_group_name}"
  listen = false
  send   = true
  manage = false
}

resource "azurerm_storage_container" "sdcauditincontainer" {
  name                 = "sdc-audit-in"
  resource_group_name  = "${local.resource_group_name}"
  storage_account_name = "${local.storage_account_name}"
  container_access_type = "private"
}

resource "azurerm_servicebus_queue" "eclipsepolicyupdateinqueue" {
  name                = "eclipse-policy-update-in"
  resource_group_name = "${local.resource_group_name}"
  namespace_name      = "${local.namespace_name}"
}

resource "azurerm_servicebus_queue_authorization_rule" "eclipsepolicyupdateinlistenrule" {
  name                = "listen"
  namespace_name      = "${local.namespace_name}"
  queue_name          = "eclipse-policy-update-in"
  resource_group_name = "${local.resource_group_name}"
  listen = true
  send   = false
  manage = false
}

resource "azurerm_servicebus_queue_authorization_rule" "eclipsepolicyupdateinsendrule" {
  name                = "send"
  namespace_name      = "${local.namespace_name}"
  queue_name          = "eclipse-policy-update-in"
  resource_group_name = "${local.resource_group_name}"
  listen = false
  send   = true
  manage = false
}

resource "azurerm_storage_container" "eclipsepolicyupdateincontainer" {
  name                 = "eclipse-policy-update-in"
  resource_group_name  = "${local.resource_group_name}"
  storage_account_name = "${local.storage_account_name}"
  container_access_type = "private"
}

resource "azurerm_servicebus_queue" "eclipsepolicycreateinqueue" {
  name                = "eclipse-policy-create-in"
  resource_group_name = "${local.resource_group_name}"
  namespace_name      = "${local.namespace_name}"
}

resource "azurerm_servicebus_queue_authorization_rule" "eclipsepolicycreateinlistenrule" {
  name                = "listen"
  namespace_name      = "${local.namespace_name}"
  queue_name          = "eclipse-policy-create-in"
  resource_group_name = "${local.resource_group_name}"
  listen = true
  send   = false
  manage = false
}

resource "azurerm_servicebus_queue_authorization_rule" "eclipsepolicycreateinsendrule" {
  name                = "send"
  namespace_name      = "${local.namespace_name}"
  queue_name          = "eclipse-policy-create-in"
  resource_group_name = "${local.resource_group_name}"
  listen = false
  send   = true
  manage = false
}

resource "azurerm_storage_container" "eclipsepolicycreateincontainer" {
  name                 = "eclipse-policy-create-in"
  resource_group_name  = "${local.resource_group_name}"
  storage_account_name = "${local.storage_account_name}"
  container_access_type = "private"
}

resource "azurerm_storage_table" "notificationlogtablestorage" {
  name                 = "notificationlog"
  resource_group_name  = "${local.resource_group_name}"
  storage_account_name = "${local.storage_account_name}"
}

resource "azurerm_storage_table" "notificationsubscribertablestorage" {
  name                 = "notificationsubscriber"
  resource_group_name  = "${local.resource_group_name}"
  storage_account_name = "${local.storage_account_name}"
}

resource "azurerm_storage_table" "sdcaudittablestorage" {
  name                 = "sdcaudit"
  resource_group_name  = "${local.resource_group_name}"
  storage_account_name = "${local.storage_account_name}"  
  lifecycle {
    ignore_changes = ["acl"]
  }
}
