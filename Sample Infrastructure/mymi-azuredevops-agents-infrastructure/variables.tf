variable "project" {
  description = "Enter the name of the project"
}

variable "app" {
  description = "Enter the name of the app (lower case characters only)"
}

variable "contact" {
  description = "Contact name for the application"
}

variable "contact_details" {
  description = "Contact informations details"
}

variable "costcentre" {
  description = "Enter the cost centre ID"
}

variable "description" {
  description = "A description for the application"
}
variable "azure_short_region" {
    description = "Define the short name for the region e.g. weu."
}
variable "azure_region" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}

variable "platform_state_key_name" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}

variable "platform_state_container_name" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}

variable "platform_state_storage_account_name" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}

variable "platform_state_resource_group_name" {
    description = "Azure region the resource is located, this is the full region name e.g. West Europe."
}

variable "vm_admin_name" {
    description = "Default user name for admin account on VM"  
}

variable "vm_admin_pass" {
    description = "Default user account password on the VM"
}

variable "vm_os_publisher" {
    description = "Azure VM Pulisher of the VM Image"
}

variable "vm_os_offer" {
    description = "Azure VM Offer - such a WindowsServer or WindowsDesktop, etc"
}

variable "vm_os_sku" {
    description = "Azure VM type of Image, 2016, 2012, etc"
}

variable "vm_os_version" {
    description = "Azure VM version - latest is by default"
}

variable "chef_validation_key" {
    description = "Chef Validation Key - Default PEM File"
}

variable "vm_name_1" {
    description = "VM Name - Server 1"
}

variable "vm_hostname_1" {
  description = "VM Hostname - Server 1"
}

variable "nic_name_vm1" {
    description = "Nic Name - VM 1"
}

variable "vm_size" {
    description = "VM Size"
}

variable "vm_disk_size_os" {
    description = "Default OS Disk Size on all servers"
}


variable "private_subnet_name" {
    description = "Name of the private subnet"
}

variable "subnet_range" {
    description = "The Subnet range for the VM"

}

variable "private_ip_address_allocation_vm" {
    description = "Assignment of IP address - static/dynamic"
    default = "static"
}

variable "private_ip_address_vm01" {
    description = "Static assigned IP address"  
}

variable "nsg_win_vm_name" {
  
}

variable "tags" {
  type        = "map"
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}
