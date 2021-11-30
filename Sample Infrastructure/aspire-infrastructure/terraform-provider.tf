provider "azurerm" {
    version = "~> 1.34"
 }

provider "azuread" {
    version = "~> 0.6"
}

terraform {
    backend "azurerm" {
        key                  = "aspire.terraform.tfstate"
    }
}

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

data "azurerm_client_config" "current" {}