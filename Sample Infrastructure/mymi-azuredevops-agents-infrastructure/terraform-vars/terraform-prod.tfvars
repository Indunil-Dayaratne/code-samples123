platform_state_key_name="platform.terraform.tfstate"
platform_state_container_name="terraform-container-ukw-prod"
platform_state_storage_account_name="terraformukwprod"
platform_state_resource_group_name = "terraform-rg-ukw-prod"

azure_short_region = "uks"
azure_region = "UK South"

vm_os_publisher = "MicrosoftWindowsServer"
vm_os_offer = "WindowsServer"
vm_os_sku = "2016-Datacenter-smalldisk"
vm_os_version = "latest"

vm_name_1 = "mymivstsagent-vm-01-prod"
vm_hostname_1 = "mymivstsag-01-p"

nic_name_vm1 = "mymivstsagent-01-nic-uks-prod"

vm_size = "Standard_D2_v3"
vm_disk_size_os = "120"

vm_admin_name = "cloudadmin"
vm_admin_pass = "Pa$$w0rd123!"

private_subnet_name = "mymivstsagent-sn-01-prod"
subnet_range = "10.8.59.0/24"

nsg_win_vm_name = "mymivstsagent-nsg-01-prod"

private_ip_address_allocation_vm = "static"
private_ip_address_vm01 = "10.8.59.6"

project = "MYMI AzureDevops Agents"
app = "mymivstsagent"
contact = "Graham Binner"
contact_details = "Graham.Binner@britinsurance.com"
costcentre = "H66"
description = "MYMI AzureDevops Agents"