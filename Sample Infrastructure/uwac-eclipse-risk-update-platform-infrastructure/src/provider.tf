# Configure the Azure Provider
provider "azurerm" {
    version = "~> 2.54.0"
    features {}
 }

# Configure the AzureRM Backend in Azure
terraform {
    required_version    = "~> 0.12.0"
    required_providers {
        azurerm             = "~> 2.54.0"
        random              = "~> 2.2"
    }
    backend "azurerm" {
        key                 = "eclipse-risk-update.012.terraform.tfstate"
    }
}

provider "azuread" {
    version = "~> 0.11"
}

data "azurerm_client_config" "current" {}