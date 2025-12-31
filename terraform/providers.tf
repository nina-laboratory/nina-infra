terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "nina-labs-central"
    storage_account_name = "terraformstaterg"
    container_name       = "tfstate"
    key                  = "nina-infra.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
