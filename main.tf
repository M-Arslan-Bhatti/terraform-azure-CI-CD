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

# ═══════════════════════════════════════════════
# LAB 3 — NSG WEB SUBNET
# Internet se HTTPS/HTTP allow
# Baaki sab Deny
# ═══════════════════════════════════════════════
resource "azurerm_network_security_group" "web" {
  # Dynamic name - locals se
  name                = "nsg-web-${local.prefix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  tags                = local.tags

  # Rule 1 - HTTPS Allow from Internet
  # var.nsg_ports.https se dynamic port aata hai
  security_rule {
    name                       = "allow-https"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.nsg_ports.https
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Rule 2 - HTTP Allow from Internet
  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.nsg_ports.http
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Rule 3 - Deny All (catch-all, sabse aakhir mein check hoti hai)
  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# NSG ko snet-web se attach karo
# for_each se banaya subnet reference kiya
resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.this["web"].id
  network_security_group_id = azurerm_network_security_group.web.id
}

# ═══════════════════════════════════════════════
# LAB 3 — NSG APP SUBNET
# Sirf Web Subnet se traffic allow
# Internet se direct access block
# ═══════════════════════════════════════════════
resource "azurerm_network_security_group" "app" {
  name                = "nsg-app-${local.prefix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  tags                = local.tags

  # Rule 1 - Sirf Web Subnet se Allow
  # var.subnets["web"].cidr se dynamic CIDR
  # var.nsg_ports.app se dynamic port
  security_rule {
    name                       = "allow-from-web"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.nsg_ports.app
    source_address_prefix      = var.subnets["web"].cidr
    destination_address_prefix = "*"
  }

  # Rule 2 - Internet se Block
  security_rule {
    name                       = "deny-internet-inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Rule 3 - Deny All (catch-all)
  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# NSG ko snet-app se attach karo
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.this["app"].id
  network_security_group_id = azurerm_network_security_group.app.id
}

# ═══════════════════════════════════════════════
# LAB 3 — NSG DATA SUBNET
# Sirf App Subnet se traffic allow
# Sab kuch aur Deny (most restrictive)
# ═══════════════════════════════════════════════
resource "azurerm_network_security_group" "data" {
  name                = "nsg-data-${local.prefix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  tags                = local.tags

  # Rule 1 - Sirf App Subnet se Allow
  # var.subnets["app"].cidr se dynamic CIDR
  # var.nsg_ports.db se dynamic port
  security_rule {
    name                       = "allow-from-app"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.nsg_ports.db
    source_address_prefix      = var.subnets["app"].cidr
    destination_address_prefix = "*"
  }

  # Rule 2 - Deny All (most restrictive tier)
  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# NSG ko snet-data se attach karo
resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.this["data"].id
  network_security_group_id = azurerm_network_security_group.data.id
}