resource "azurerm_virtual_machine_extension" "chef-agent" {
  count                      = "${var.install_chef_agent == "true" ? 1 : 0}"
  name                       = "ChefAgent"
  location                   = "${var.resource_group_location}"
  resource_group_name        = "${var.resource_group_name}"
  virtual_machine_name       = "${var.resource_prefix}-vm-${var.short_region}-${var.environment}"
  depends_on                 = ["azurerm_virtual_machine.azurevm"]
  publisher                  = "Chef.Bootstrap.WindowsAzure"
  type                       = "LinuxChefClient"
  type_handler_version       = "1210.12"
  settings = <<SETTINGS
    {
        "client_rb": "${var.chef_client_rb}",
        "validation_key_format": "base64encoded",
        "bootstrap_options": {
            "chef_node_name": "${var.vm_hostname}",
            "chef_server_url": "${var.chef_server_url}",
            "validation_client_name": "${var.chef_validation_client_name}"
        }
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
        "validation_key": "${var.chef_validation_key}"
    }
PROTECTED_SETTINGS
}
