resource "azurerm_virtual_machine_extension" "domainJoin" {
    name                    = "Domain-Join"
    virtual_machine_id      = azurerm_windows_virtual_machine.vm.*.id[count.index]
    publisher               = "Microsoft.Compute"
    type                    = "JSONADDomainExtension"
    type_handler_version    = "1.0"
    tags                    = var.Tags

    settings                = <<SETTINGS
{
    "Name": "wren.co.uk",
    "OUPath": "OU=Azure,OU=Servers,OU=Brit,DC=wren,DC=co,DC=uk",
    "User": "SVC-djas@wren.co.uk",
    "Restart": "true",
    "Options": "3"
}
SETTINGS

    protected_settings      = <<PROTECTED
{
    "Password": "${var.DomainPassword}"
}
PROTECTED

    count                   = var.Linux == true || var.DomainJoin == false ? 0 : local.vm_count
}

resource "azurerm_virtual_machine_extension" "LocalAdmin_DisableFirewall" {
    name                    = "AddLocalAdmin_DisableFirewall"
    virtual_machine_id      = azurerm_windows_virtual_machine.vm.*.id[count.index]
    publisher               = "Microsoft.Compute"
    type                    = "CustomScriptExtension"
    type_handler_version    = "1.8"
    tags                    = var.Tags

    settings                = <<SETTINGS
{
    "commandToExecute": "powershell -Command \"net localgroup administrators /add 'SEC-AzureCloud_Ops@wren.co.uk'; netsh advfirewall set allprofiles state off; exit 0\""
}
SETTINGS

    depends_on              = [azurerm_virtual_machine_extension.domainJoin]
    count                   = var.Linux == true || var.DomainJoin == false ? 0 : local.vm_count
}

resource "azurerm_virtual_machine_extension" "DisableFirewall" {
    name                    = "DisableFirewall"
    virtual_machine_id      = azurerm_windows_virtual_machine.vm.*.id[count.index]
    publisher               = "Microsoft.Compute"
    type                    = "CustomScriptExtension"
    type_handler_version    = "1.8"
    tags                    = var.Tags

    settings                = <<SETTINGS
{
    "commandToExecute": "powershell -Command \"netsh advfirewall set allprofiles state off; exit 0\""
}
SETTINGS

    count                   = var.Linux == false && var.DomainJoin == false ? local.vm_count : 0
}
