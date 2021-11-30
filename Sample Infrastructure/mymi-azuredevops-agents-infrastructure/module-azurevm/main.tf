
resource "azurerm_virtual_machine" "azurevm" {
  name                  = "${var.vm_name}"
  location              = "${var.resource_group_location}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids = ["${element(azurerm_network_interface.azurevm.*.id, count.index)}"]
  license_type          = "${var.vm_hybrid_license == "true" ? "Windows_Server" : "Windows_Client"}"
  vm_size               = "${var.vm_size}"
  depends_on            = ["azurerm_network_interface.azurevm"]
  delete_os_disk_on_termination = false

  storage_image_reference {
    publisher = "${var.vm_os_publisher}"
    offer     = "${var.vm_os_offer}"
    sku       = "${var.vm_os_sku}"
    version   = "${var.vm_os_version}"
  }

  storage_os_disk {
    name              = "${var.os_disk_name}"    
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "${var.disk_size_gb == "-1" ? 127 : "${var.disk_size_gb}"}"
  }

  os_profile {
    computer_name  = "${var.vm_hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }

  tags = "${var.tags}"
}