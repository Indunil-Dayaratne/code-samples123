platform_state_key_name="platform.terraform.tfstate"
platform_state_container_name="terraform-container-ukw-prod"
platform_state_storage_account_name="terraformukwprod"
platform_state_resource_group_name = "terraform-rg-ukw-prod"

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

private_subnet_name = "fileservices-private-subnet-prod"
subnet_range = "10.8.27.0/24"
nsg_win_vm_name = "fileservices-vm-prod-nsg-prod"
private_ip_address_allocation_vm = "static"
private_ip_address_vm = "10.8.27.8"

project = "fileservices"
app = "fileservices"
contact = "Dan King"
contact_details = "dan.king@britinsurance.com"
costcentre = "N37"
description = "File Services"

storage_account_name = "platformsauksprod"
storage_account_key = ""