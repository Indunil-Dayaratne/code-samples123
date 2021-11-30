resource "azurerm_availability_set" "azurevm" {
  name                         = "${var.resource_prefix}-avset-${var.short_region}-${var.environment}"
  location                     = "${var.resource_group_location}"
  resource_group_name          = "${var.resource_group_name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags                         = "${var.tags}"
}

resource "azurerm_virtual_machine" "azurevm" {
  name                          = "${var.resource_prefix}-vm-${var.short_region}-${var.environment}"
  location                      = "${var.resource_group_location}"
  resource_group_name           = "${var.resource_group_name}"
  availability_set_id           = "${azurerm_availability_set.azurevm.id}"
  network_interface_ids         = ["${element(azurerm_network_interface.azurevm.*.id, count.index)}"]
  vm_size                       = "${var.vm_size}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${var.vm_os_publisher}"
    offer     = "${var.vm_os_offer}"
    sku       = "${var.vm_os_sku}"
    version   = "${var.vm_os_version}"
  }

  storage_os_disk {
    name              = "${var.resource_prefix}-osdisk-${var.short_region}-${var.environment}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "${var.disk_size_gb == "-1" ? "" : "${var.disk_size_gb}"}"
  }

  os_profile {
    computer_name  = "${var.vm_hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = "${var.tags}"
}