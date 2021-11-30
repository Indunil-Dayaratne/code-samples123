module "logicmonitor-vm-1" {
    source                    = "./module-azurevm"

    resource_prefix               = "${lookup(local.tags,"app")}-01"
    short_region                  = "${data.terraform_remote_state.platform.platform_region_prefix}"
    environment                   = "${terraform.workspace}"
    
    vm_name                       = "${var.vm_name_1}"
    vm_hostname                   = "${var.vm_hostname_1}"
    vm_size                       = "${var.vm_size}"
    disk_size_gb                  = "${var.disk_size_gb}"

    resource_group_name           = "${azurerm_resource_group.app-rg.name}"
    resource_group_location       = "${azurerm_resource_group.app-rg.location}"

    vnet_subnet_id                = "${azurerm_subnet.subnet_internal.id}"
    network_security_group_id     = "${azurerm_network_security_group.nsg.id}"
    public_ip                     = "false"
    network-interface-name        = "${var.nic_name_vm1}"

    private_ip_address_allocation = "${var.private_ip_address_allocation_vm}"
    private_ip_address            = "${var.private_ip_address_vm01}"

    vm_os_publisher               = "${var.vm_os_publisher}"
    vm_os_offer                   = "${var.vm_os_offer}"
    vm_os_sku                     = "${var.vm_os_sku}"
    vm_os_version                 = "${var.vm_os_version}"

    os_disk_name                  = "${local.disk_name_main_os_1}"
    disk_size_gb                  = "${var.vm_disk_size_os}"

    admin_username                = "${var.vm_admin_name}"
    admin_password                = "${var.vm_admin_pass}"

    install_anti_malware          = "true"
    install_oms_agent             = "true"

    chef_validation_key           = "${var.chef_validation_key}"

    oms_workspace_id              = "${data.terraform_remote_state.platform.platform_oms_workspace_id}"
    oms_workspace_key             = "${data.terraform_remote_state.platform.platform_oms_key}"

    tags                          = "${local.tags}"
}