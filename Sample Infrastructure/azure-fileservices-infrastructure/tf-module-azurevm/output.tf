output "vm_id" {
  description = "Virtual machine ids created."
  value       = "${azurerm_virtual_machine.azurevm.id}"
}

output "vm_name" {
  description = "Name of the Virtual Machine in Azure"
  value       = "${var.resource_prefix}-vm-${var.short_region}-${var.environment}"
}

output "network_interface_ids" {
  description = "ids of the vm nics provisoned."
  value       = "${azurerm_network_interface.azurevm.*.id}"
}

output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = "${azurerm_network_interface.azurevm.*.private_ip_address}"
}

output "public_ip_id" {
  description = "id of the public ip address provisoned."
  value       = "${azurerm_public_ip.azurevm.*.id}"
}

output "public_ip_address" {
  description = "The actual ip address allocated for the resource."
  value       = "${azurerm_public_ip.azurevm.*.ip_address}"
}

output "availability_set_id" {
  description = "id of the availability set where the vms are provisioned."
  value       = "${azurerm_availability_set.azurevm.id}"
}
