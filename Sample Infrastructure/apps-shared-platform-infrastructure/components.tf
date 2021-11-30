// Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_group_name}"
  location = "${var.azure_region}"
  tags     = "${local.tags}"
}

resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "${local.app_service_plan_name}"
  location            = "${var.azure_region}"
  resource_group_name = "${local.resource_group_name}"
  tags                = "${local.tags}"
  depends_on          = ["azurerm_resource_group.rg"]

  sku {
    tier = "Premium"
    size = "P2V2"
  }
}

resource "azurerm_app_service_plan" "apiappserviceplan" {
  count               = "${local.api_app_service_plan_count}"
  name                = "${local.api_app_service_plan_name}"
  location            = "${var.azure_region}"
  resource_group_name = "${local.resource_group_name}"
  tags                = "${local.tags}"
  depends_on          = ["azurerm_resource_group.rg"]

  sku {
    tier = "Premium"
    size = "P2V2"
  }
}

resource "azurerm_key_vault" "keyvault" {
  name                        = "${local.key_vault_name}"
  location                    = "${var.azure_region}"
  resource_group_name         = "${local.resource_group_name}"
  enabled_for_disk_encryption = true
  tenant_id                   = "${var.tenant_id}"

  sku {
    name = "standard"
  }

  access_policy {
    tenant_id = "${var.tenant_id}"
    object_id = "${var.spn_object_id}"
  
    secret_permissions = [
      "get",
      "list",
      "set"
    ]
  }

  tags = "${local.tags}"

  lifecycle {
    ignore_changes = ["access_policy"]
  }
  depends_on          = ["azurerm_resource_group.rg"]
}
