platform_state_key_name="platform.terraform.tfstate"
platform_state_container_name="terraform-container-ukw-prod"
platform_state_storage_account_name="terraformukwprod"
platform_state_resource_group_name = "terraform-rg-ukw-prod"

azure_short_region = "uks"
azure_region = "UK South"

project = "Azure Chef"
app = "chefserver"
appname = "chefautomateserver"
appchefsupermkt = "chefsupermarket"
contact = "Harry Hall"
contact_details = "ext 100684"
costcentre = "N37"
description = "Chef Server, Chef Automate Server and Chef Supermarket for Azure"

private_ip_address_allocation = "static"
private_ip_address_chef_svr  = "10.8.5.4"
private_ip_address_chef_auto  = "10.8.5.5"
private_ip_address_chef_supermkt = "10.8.5.6"

private_subnet_name = "chefserver-private-subnet-01-prod"
subnet_range = "10.8.5.0/24"

nsg_chefserver_name = "chefserver-vm-01-prod-nsg-prod"
nsg_chefautomateserver_name = "chefautomateserver-vm-02-prod-nsg-prod"
nsg_chef_supermkt_name = "chefsupermarket-vm-03-prod-nsg-prod"

vm_admin_name = "chefAdmin"
vm_admin_password = "Mw%|uxpHaQv$dOcC"

vm_disk_size = "1000"
vm_disk_size_chefsupermkt = "50"

storage_acc_name = "chefstoreuksprod"
storage_container_name = "chefstoreuksprodcontainer"
storage_container_type = "blob"
storage_account_tier = "Standard"
storage_account_rep_type = "LRS"
storage_account_kind = "StorageV2"

asr_policy_frequency = "Daily"
asr_policy_time = "19:00"
asr_daily_retention = "30"
