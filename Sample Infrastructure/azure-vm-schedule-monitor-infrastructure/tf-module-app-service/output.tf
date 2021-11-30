#****************** ONLY ENABLE IF YOU REQUIRE NETWORK.TF ******************

# output "network_interface_ids" {
#   description = "ids of the vm nics provisoned."
#   value       = "${azurerm_network_interface.appservicenet.*.id}"
# }

# output "network_interface_private_ip" {
#   description = "private ip addresses of the vm nics"
#   value       = "${azurerm_network_interface.appservicenet.*.private_ip_address}"
# }

# output "public_ip_id" {
#   description = "id of the public ip address provisoned."
#   value       = "${azurerm_public_ip.appservicepub.*.id}"
# }

# output "public_ip_address" {
#   description = "The actual ip address allocated for the resource."
#   value       = "${azurerm_public_ip.appservicepub.*.ip_address}"
# }
