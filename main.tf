terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # ← YEH NAYA ADD HUA HAI - required_providers ke baad
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "starslanterraform001"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "app" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.tags
}