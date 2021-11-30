resource "azurerm_recovery_services_vault" "chef-vault" {
  name                      = "${local.asr_name}"
  resource_group_name       = "${azurerm_resource_group.app-rg.name}"
  location                  = "${azurerm_resource_group.app-rg.location}"
  sku                       = "standard"

  tags                      = "${local.tags}"
}