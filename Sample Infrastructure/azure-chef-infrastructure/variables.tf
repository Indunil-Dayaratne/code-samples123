variable "project" {
  description = "Enter the name of the project"
}

variable "app" {
  description = "Enter the name of the app (lower case characters only)"
}

variable "appname" {
  description = "Enter the name of the app (lower case characters only)"
}

variable "appchefsupermkt" {
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

variable "private_ip_address_allocation" {
  description = "Defines how a Private IP address is assigned. Options are Static or Dynamic."
  default     = "dynamic"
}

variable "private_ip_address_chef_svr" {
  description = "Assigns the instance a private IP address."
}

variable "private_ip_address_chef_auto" {
  description = "Assigns the instance a private IP address."
}

variable "private_ip_address_chef_supermkt" {
    description = "Assigns the instance a private IP address."
}

variable "private_subnet_name" {
  description = "Creates private subnet name"
}

variable "subnet_range" {
  description = "Creates subnet range"
}

variable "nsg_chefserver_name" {
  description = "Network security group for the chef server"
}

variable "nsg_chefautomateserver_name" {
  description = "Network security group for the chef auotmate server"
}

variable "nsg_chef_supermkt_name" {
    description = "Network security group for the chef supermarket"
}


variable "vm_admin_name" {
  description = "Admin username for the VM in Azure"
}


variable "vm_admin_password" {
  description = "Admin password for the VM in Azure"
}

variable "vm_disk_size" {
  description = "Size of the disk OS on the VM"
}

variable "vm_disk_size_chefsupermkt" {
    description = "Size of the disk OS on the VM"
}


variable "storage_acc_name" {
  type        = "string"
  description = "Storage account name"
}

variable "storage_container_name" {
  type        = "string"
  description = "Storage container name"
}

variable "storage_container_type" {
  type        = "string"
  description = "Storage container type"
}

variable "storage_account_tier" {
  type        = "string"
  description = "Storage account tier"
}

variable "storage_account_rep_type" {
  type        = "string"
  description = "Storage replication type"
}

variable "storage_account_kind" {
  type        = "string"
  description = "Storage Account type - StorageV2"
}

variable "asr_policy_frequency" {
  description = "The frequency of the ASR backup policy daily, weekly, monthly."  
}

variable "asr_policy_time" {
  description = "The time the ASR backup policy will run, 24 hour clock format"  
}
variable "asr_daily_retention" {
  description = "The number of days to retain daily backups"  
}

variable "tags" {
  type        = "map"
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}