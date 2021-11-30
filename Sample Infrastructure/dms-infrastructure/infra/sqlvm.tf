module "sqlvm" {
    # the TerraformModules repo can be found here: https://dev.azure.com/britgroupservices/PSCloudModules/_git/TerraformModules
    # if running TF locally, please clone it to a sibling directory of brit-dms-source 
    source          = "../../TerraformModules/Modules/VirtualMachine"
    Location        = local.tags.location
    ResourceGroup   = azurerm_resource_group.rg.name
    AdminPassword   = [azurerm_key_vault_secret.sqlvm_admin_password.value]
    Subnet          = azurerm_subnet.snet.id
    Nsg	            = azurerm_network_security_group.nsg.id
    Tags            = local.tags
    Size            = var.SqlVm.Size
    OsDiskType      = "Standard_LRS"
    VmImage         = {
        Publisher = "microsoftsqlserver"
        Offer = "sql2019-ws2019"
        Sku = var.SqlVm.Sku
        Version = "latest"
    }
    DomainPassword  = data.azurerm_key_vault_secret.domain_join_password.value
    Project         = local.tags.app
    Environment     = terraform.workspace
    VmCount         = 1
    AvailabilitySet = false
    BootDiagnostics = false
}

resource "azurerm_managed_disk" "sql_data_disk" {
    name                 = "${module.sqlvm.VirtualMachineComputerName[0]}-data-disk-1"
    location             = azurerm_resource_group.rg.location
    resource_group_name  = azurerm_resource_group.rg.name
    storage_account_type = "Standard_LRS"
    create_option        = "Empty"
    disk_size_gb         = 127

    tags                 = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "sql_data_disk_attachment" {
    managed_disk_id    = azurerm_managed_disk.sql_data_disk.id
    virtual_machine_id = module.sqlvm.VirtualMachineID[0]
    lun                = "10"
    caching            = "ReadWrite"
}