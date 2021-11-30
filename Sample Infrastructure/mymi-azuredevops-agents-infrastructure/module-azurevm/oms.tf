resource "azurerm_virtual_machine_extension" "oms_mma" {
  count                         = "${var.install_oms_agent == "true" ? 1 : 0}"
  name                          = "OMSExtension"
  location                      = "${var.resource_group_location}"
  resource_group_name           = "${var.resource_group_name}"
  virtual_machine_name          = "${element(azurerm_virtual_machine.azurevm.*.name, count.index)}"
  depends_on                    = ["azurerm_virtual_machine.azurevm", "azurerm_virtual_machine_extension.app-am"]
  publisher                     = "Microsoft.EnterpriseCloud.Monitoring"
  type                          = "MicrosoftMonitoringAgent"
  type_handler_version          = "1.0"
  auto_upgrade_minor_version    = "True"
  tags                           = "${var.tags}"
  
 settings = <<-BASE_SETTINGS
 {
   "workspaceId" : "${var.oms_workspace_id}"
 }
 BASE_SETTINGS

 protected_settings = <<-PROTECTED_SETTINGS
 {
   "workspaceKey" : "${var.oms_workspace_key}"
 }
 PROTECTED_SETTINGS
}