output "VirtualMachineID" {
  value = var.Linux == true ? azurerm_linux_virtual_machine.vm.*.id : azurerm_windows_virtual_machine.vm.*.id
}
output "VirtualMachineName" {
	value = var.Linux == true ? azurerm_linux_virtual_machine.vm.*.name : azurerm_windows_virtual_machine.vm.*.name
}
output "VirtualMachineComputerName" {
	value = var.Linux == true ? azurerm_linux_virtual_machine.vm.*.computer_name : azurerm_windows_virtual_machine.vm.*.computer_name
}
output "VirtualMachineNIC" {
  value = var.Linux == true ? zipmap(azurerm_linux_virtual_machine.vm.*.id, azurerm_network_interface.nic.*.id) : zipmap(azurerm_windows_virtual_machine.vm.*.id, azurerm_network_interface.nic.*.id)
}
output "VirtualMachineOsDisk" {
  value   = var.Linux == true ? azurerm_linux_virtual_machine.vm[*].os_disk[0].name : azurerm_windows_virtual_machine.vm[*].os_disk[0].name
}
