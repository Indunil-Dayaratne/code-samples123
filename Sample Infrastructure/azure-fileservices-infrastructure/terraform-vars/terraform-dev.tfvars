platform_state_key_name="platform.terraform.tfstate"
platform_state_container_name="terraform-container-uks-dev"
platform_state_storage_account_name="terraformuksdev"
platform_state_resource_group_name = "terraform-rg-uks-dev"

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
subnet_range = "10.0.5.0/24"
nsg_win_vm_name = "winvmnsgtraining-vm-prod-nsg-prod"
private_ip_address_allocation_vm = "static"
private_ip_address_vm = "10.0.5.8"

project = "terraformtraining"
app = "wintftrain"
contact = "Harry Hall"
contact_details = "ext 100684"
costcentre = "N37"
description = "Terraform training Windows VM application"

storage_account_name = "platformsauksdev"
storage_account_key = "Wsc3MUrhe2lTvy5RoEirQI/H5ANRK9vloN0NJTVvAuDxPLOJNrKqMwzMmoQJ86j7c+ni7I7fHesH7cd1IDG4Tg=="