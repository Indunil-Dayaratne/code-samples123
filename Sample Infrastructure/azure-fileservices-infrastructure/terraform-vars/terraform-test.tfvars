platform_state_key_name="platform.terraform.tfstate"
platform_state_container_name="terraform-container-uks-test"
platform_state_storage_account_name="terraformukstest"
platform_state_resource_group_name = "terraform-rg-uks-test"

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

private_subnet_name = "monitortest-private-subnet-test"
subnet_range = "10.1.5.0/24"
nsg_win_vm_name = "monitortest-vm-prod-nsg-test"
private_ip_address_allocation_vm = "static"
private_ip_address_vm = "10.1.5.10"

project = "monitoringtest"
app = "monitortest"
contact = "Ben Saunders"
contact_details = "ext 100862"
costcentre = "N37"
description = "Base Azure VM"

storage_account_name = "platformsaukstest"
storage_account_key = "nsqfXNTQQG1yfXaN+uf6f22ExbX0NWg3A1eryAKiu2o6VGVmR8xGNwxBTiWr/Ywuyw3ijXoP1X3TjRCOmFAjyg=="