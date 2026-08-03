# ═══════════════════════════════════════════════
# LAB 6 — AZURE FIREWALL
# Central network filtering + egress control
# ⚠️ COSTLY: ~$900+/month — turant verify karke destroy karna!
# ═══════════════════════════════════════════════

resource "azurerm_public_ip" "firewall" {
  name                = "pip-fw-${local.prefix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_firewall" "hub" {
  name                = "afw-${local.prefix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  tags                = local.tags

  ip_configuration {
    name                 = "fw-ip-config"
    subnet_id            = azurerm_subnet.this["AzureFirewallSubnet"].id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}