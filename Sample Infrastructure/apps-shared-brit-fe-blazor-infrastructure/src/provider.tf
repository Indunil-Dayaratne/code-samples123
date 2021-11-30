terraform {
  required_version = ">= 0.15"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.0"
    }
  }

  backend "azurerm" {
    key = "shared-digital-brit-ui.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}