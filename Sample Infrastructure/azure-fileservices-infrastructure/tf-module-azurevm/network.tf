resource "azurerm_public_ip" "azurevm" {
  count                        = "${var.public_ip == "true" ? 1 : 0 }"
  name                         = "${var.resource_prefix}-pip-${var.short_region}-${var.environment}"
  location                     = "${var.resource_group_location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "${var.public_ip_address_allocation}"
  tags                         = "${var.tags}"
}

resource "azurerm_network_interface" "azurevm" {
  count                           = "1"
  name                            = "${var.resource_prefix}-nic-${var.short_region}-${var.environment}"
  location                        = "${var.resource_group_location}"
  resource_group_name             = "${var.resource_group_name}"
  network_security_group_id       = "${var.network_security_group_id == "false" ? "" : "${var.network_security_group_id}"}"

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = "${var.vnet_subnet_id}"
    private_ip_address_allocation = "${var.private_ip_address_allocation}"
    private_ip_address            = "${var.private_ip_address}"
    public_ip_address_id          = "${var.public_ip == "true" ? element(concat(azurerm_public_ip.azurevm.*.id, list("")), count.index) : ""}"
  }

  tags                            = "${var.tags}"
}