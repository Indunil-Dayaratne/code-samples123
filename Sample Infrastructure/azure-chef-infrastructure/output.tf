output "chef_subnet_id" {
  description = "id of the subnet set where the vms are provisioned."
  value       = "${azurerm_subnet.subnet_internal.id}"
}