terraform {
    required_version    = "~> 0.12.31"
    required_providers {
        azurerm             = "~> 2.22"
        random              = "~> 2.2"
        azuread             = "~> 0.11"
        null                = "~> 2.0"
    }
    backend "azurerm" {
        key                 = "brit-dms-redirector.012.terraform.tfstate"
    }
}

provider "azurerm" {
    version             = "~> 2.22"
    features {}
}

provider "azuread" {
    version = "~> 0.11"
}

provider "random" {
    version             = "~> 2.2"
}

provider "null" {
    version = "~> 2.0"
}

data "azurerm_client_config" "current" {}
