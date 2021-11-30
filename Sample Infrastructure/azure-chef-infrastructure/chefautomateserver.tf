module "chefauotmateserver-vm" {
  source                    = "./vm-linux-module"

  resource_prefix           = "${lookup(local.tags,"appname")}"
  short_region              = "${data.terraform_remote_state.platform.platform_region_prefix}"
  environment               = "${terraform.workspace}"

  vm_hostname               = "${lookup(local.tags,"appname")}"
  vm_size                   = "Standard_D2_v2"

  resource_group_name       = "${azurerm_resource_group.app-rg.name}"
  resource_group_location   = "${azurerm_resource_group.app-rg.location}"

  vnet_subnet_id            = "${azurerm_subnet.subnet_internal.id}"
  network_security_group_id = "${azurerm_network_security_group.prod_chefautosvr_ngs.id}"
  public_ip                 = "false"

  private_ip_address_allocation = "${var.private_ip_address_allocation}"
  private_ip_address            = "${var.private_ip_address_chef_auto}"

  vm_os_publisher           = "Canonical"
  vm_os_offer               = "UbuntuServer"
  vm_os_sku                 = "18.04-LTS"

  disk_size_gb              = "${var.vm_disk_size}"

  admin_username            = "${var.vm_admin_name}"
  admin_password            = "${var.vm_admin_password}"

  install_chef_agent        = "false"

  oms_workspace_id          = "${data.terraform_remote_state.platform.platform_oms_workspace_id}"
  oms_workspace_key         = "${data.terraform_remote_state.platform.platform_oms_key}"

  tags                      = "${local.tags}"
}

resource "azurerm_recovery_services_protected_vm" "chefautosvr_prod" {
  resource_group_name = "${azurerm_resource_group.app-rg.name}"
  recovery_vault_name = "${azurerm_recovery_services_vault.chef-vault.name}"
  source_vm_id        = "${module.chefauotmateserver-vm.vm_id}"
  backup_policy_id    = "${azurerm_recovery_services_protection_policy_vm.chef-asr-policy.id}"
}