# ═══════════════════════════════════════════════
# LAB 6 — AZURE BASTION
# Secure VM access bina public IP diye
# ⚠️ COSTLY: ~$140/month — turant verify karke destroy karna!
# ═══════════════════════════════════════════════

resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion-${local.prefix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_bastion_host" "hub" {
  name                = "bas-${local.prefix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  sku                 = "Standard"
  tags                = local.tags

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.this["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}