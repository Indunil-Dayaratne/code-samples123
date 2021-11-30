platform_state_key_name="platform.terraform.tfstate"
platform_state_container_name="terraform-container-ukw-nonprod"
platform_state_storage_account_name="terraformukwnonprod"
platform_state_resource_group_name = "terraform-rg-ukw-nonprod"

azure_short_region = "uks"
azure_region = "UK South"

vm_os_publisher = "MicrosoftWindowsServer"
vm_os_offer = "WindowsServer"
vm_os_sku = "2016-Datacenter"
vm_os_version = "latest"

vm_disk_size = "500"
extra_disk_size = "500"

vm_admin_name = "azure"
vm_admin_password = "Pa$$w0rd123!"

private_subnet_name = "winvmtraining-private-subnet-prod"
subnet_range = "10.9.5.0/24"
nsg_win_vm_name = "winvmnsgtraining-vm-prod-nsg-prod"
private_ip_address_allocation_vm = "static"
private_ip_address_vm = "10.9.5.8"

project = "terraformtraining"
app = "wintftrain"
contact = "Harry Hall"
contact_details = "ext 100684"
costcentre = "N37"
description = "Terraform training Windows VM application"

storage_account_name = "platformsauksnonprod"
storage_account_key = "1CEp373VwPZ2fogiFfFPzACAC6VWO16sENX9ZWUNmthXT9/7uOPFV+rtmr3vUUbSGkg9kcGkPcjVm9yoJIAJlw=="