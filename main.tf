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

# ═══════════════════════════════════════════════
# EXISTING CODE:
# terraform block      ← Upar hai
# provider block       ← Upar hai
# resource_group block ← Upar hai
#
# YAHAN SE NAYA ADD KAO ↓
# ═══════════════════════════════════════════════

# VIRTUAL NETWORK
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-${local.prefix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  address_space       = [var.vnet_cidr]
  tags                = local.tags
}

# SUBNETS - for_each se multiple bante hain
resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.app.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [each.value.cidr]
}