# Configure the Azure Provider
provider "azurerm" {
    version = "~> 1.19"
 }

# Configure the AzureRM Backend in Azure
terraform {
    backend "azurerm" {
        #Update the state file name for your new app  in format your-app-shortname.terraform.tfstate.  Uncomment the line below when done.
        key                  = "vmscheduletaskmonitor.terraform.tfstate"
    }
}

# Import the remote state of the platform level items
data "terraform_remote_state" "platform" {
    backend = "azurerm"
    workspace = "${terraform.workspace}"
    config {
        key                  = "${var.platform_state_key_name}"
        container_name       = "${var.platform_state_container_name}"
        storage_account_name = "${var.platform_state_storage_account_name}"
        resource_group_name  = "${var.platform_state_resource_group_name}"
    }
}