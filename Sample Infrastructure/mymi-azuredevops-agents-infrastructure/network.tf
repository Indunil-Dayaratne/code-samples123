
resource "azurerm_subnet" "subnet_internal" {
  name                 = "${var.private_subnet_name}"
  virtual_network_name = "${data.terraform_remote_state.platform.platform_vnet_name}"
  resource_group_name  = "${data.terraform_remote_state.platform.platform_rg_name}"
  address_prefix       = "${var.subnet_range}"
}