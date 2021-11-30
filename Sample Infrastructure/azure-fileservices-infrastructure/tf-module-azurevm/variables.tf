variable "public_ip" {
    description = "Assign a public IP to the instance or not (true to apply)"
    default     = "false"
}

variable "resource_prefix" {
    description = "Virtual machine host prefix (to identify what this is)"
}

variable "short_region" {
    description = "Define the short name for the region - TODO - Change this to a map"
}

variable "environment" {
    description = "The shortname for the environment - TODO - Change this to a map"
}

variable "resource_group_location" {
    description = "Resource group location"
}

variable "resource_group_name" {
    description = "Name of the resource group"
}

variable "public_ip_address_allocation" {
  description = "Defines how a Public IP address is assigned. Options are Static or Dynamic."
  default     = "dynamic"
}

variable "private_ip_address_allocation" {
  description = "Defines how a Private IP address is assigned. Options are Static or Dynamic."
  default     = "dynamic"
}

variable "private_ip_address" {
  description = "Assigns the instance a private IP address."
  default     = ""
}

variable "vnet_subnet_id" {
    description = "The VNETs Subnet ID of the network we need to attach this instance too"
}

variable "network_security_group_id" {
    description = "Assign an network security group ID to this instance"
    default = "false"
}

variable "vm_size" {
    description = "Enter the size of the VM (Default = Standard_DS1_v2)"
    default = "Standard_DS1_v2"
}

variable "vm_hybrid_license" {
  description = "Set to false to use non-hybrid license"
  default = "true"
}

variable "vm_os_publisher" {
  description = "The name of the publisher of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  default     = "MicrosoftWindowsServer"
}

variable "vm_os_offer" {
  description = "The name of the offer of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  default     = "WindowsServer"
}

variable "vm_os_sku" {
  description = "The sku of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  default     = "2016-Datacenter"
}

variable "vm_os_version" {
  description = "The version of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  default     = "latest"
}

variable "admin_username" {
  description = "The admin username of the VM that will be deployed"
  default     = "azureuser"
}

variable "admin_password" {
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure"
}

variable "vm_hostname" {
  description = "local name of the VM"
  default     = "myvm"
}

variable "disk_size_gb" {
  description = "Size of the local disk in GB. -1 Means default"
  default = "-1"
}

variable "install_anti_malware" {
  description = "Do you wish to install anti malware onto the virtual machine"
  default     = "true"
}

variable "install_chef_agent" {
  description = "Do you wish to install the chef agent extension onto the virtual machine"
  default     = "true"
}

variable "install_oms_agent" {
  description = "Do you wish to install the OMS agent onto the virtual machine"
  default     = "true"
}

variable "chef_validation_key" {
  description = "(BASE64 ENCODED) Chef Organisation validation key to add the node to the Chef Server"
  default = "SET IF INSTALL_CHEF_AGENT IS TRUE"
}

variable "chef_validation_client_name" {
  description = "Chef Validation Client name for the certificate"
  default = "britinsurance-validator"
  
}

variable "chef_server_url" {
  description = "The Chef Server url"
  default = "https://chefserver.wren.co.uk/organizations/britinsurance"
}

variable "chef_client_rb" {
  description = "client.rb config for direct overrides"
  default = "ssl_verify_mode :verify_none"
  
}

variable "oms_workspace_id" {
  description = "OMS Workspace ID from Platform"
  default = ""
}

variable "oms_workspace_key" {
  description = "OMS Workspace Key"  
  default = ""
}

variable "storage_account_name" {
    description = "Name of the storage account for the environment"
}

variable "storage_account_key" {
    description = "Access key for the storage account for the environment"
}

variable "tags" {
  type        = "map"
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}