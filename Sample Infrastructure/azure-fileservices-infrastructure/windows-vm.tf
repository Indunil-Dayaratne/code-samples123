module "windows-vm" {
  source                        = "./tf-module-azurevm"

  resource_prefix               = "${lookup(local.tags,"app")}"
  short_region                  = "${data.terraform_remote_state.platform.platform_region_prefix}"
  environment                   = "${terraform.workspace}"

  vm_hostname                   = "${lookup(local.tags,"app")}"
  vm_size                       = "Standard_D2_v3"

  resource_group_name           = "${azurerm_resource_group.app-rg.name}"
  resource_group_location       = "${azurerm_resource_group.app-rg.location}"

  vnet_subnet_id                = "${azurerm_subnet.subnet_internal.id}"
  network_security_group_id     = "${azurerm_network_security_group.win_vm_ngs.id}"
  public_ip                     = "false"

  private_ip_address_allocation = "${var.private_ip_address_allocation_vm}"
  private_ip_address            = "${var.private_ip_address_vm}"

  vm_os_publisher               = "${var.vm_os_publisher}"
  vm_os_offer                   = "${var.vm_os_offer}"
  vm_os_sku                     = "${var.vm_os_sku}"
  vm_os_version                 = "${var.vm_os_version}"

  disk_size_gb                  = "${var.vm_disk_size}"

  admin_username                = "${var.vm_admin_name}"
  admin_password                = "${var.vm_admin_password}"

  install_anti_malware          = "true"
  install_oms_agent             = "true"

  oms_workspace_id              = "${data.terraform_remote_state.platform.platform_oms_workspace_id}"
  oms_workspace_key             = "${data.terraform_remote_state.platform.platform_oms_key}"

  storage_account_name          = "${var.storage_account_name}"
  storage_account_key           = "${var.storage_account_key}"

  tags                          = "${local.tags}"
}