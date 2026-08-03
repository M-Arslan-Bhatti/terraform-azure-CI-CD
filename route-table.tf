# ═══════════════════════════════════════════════
# LAB 3b — ROUTE TABLES (UDR - User Defined Routes)
# Kya karta hai: Traffic ka PATH control karta hai
# NSG se FARQ: NSG = "kya allow ho", Route = "kahan se jaye"
# ═══════════════════════════════════════════════

resource "azurerm_route_table" "app" {
  name                = "rt-app-${local.prefix}"
  # "rt-" = route table ka convention prefix

  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  tags                = local.tags

  route {
    # route → NESTED BLOCK, actual route rule define karta hai
    # Multiple route blocks ho sakte hain ek table mein

    name = "default-route"
    # Route ka naam, identification ke liye

    address_prefix = "0.0.0.0/0"
    # 0.0.0.0/0 → SPECIAL CIDR jiska matlab "SAB KUCH"
    #             (har possible IP address)
    # Yeh DEFAULT ROUTE hai - matches everything
    # Change kar sakte ho: Specific CIDR bhi de sakte ho
    #                      jaise "10.0.0.0/8" sirf internal traffic ke liye

    next_hop_type = "Internet"
    # next_hop_type → Traffic KAHAN JAYE
    # Options:
    #   "Internet"         → Direct internet (abhi yeh use kiya)
    #   "VirtualAppliance" → Firewall/NVA (production mein yeh)
    #   "VnetLocal"        → Same VNet mein rahe
    #   "None"             → Traffic drop karo
    # Change kar sakte ho: Production mein "VirtualAppliance"
    #                      use karenge jab Firewall banayenge
  }
}

resource "azurerm_subnet_route_table_association" "app" {
  # Route Table ko Subnet se attach karta hai
  # Bina isके route table bana to lega, lagega nahi kahin

  subnet_id      = azurerm_subnet.this["app"].id
  route_table_id = azurerm_route_table.app.id
}

# NOTE: data subnet ka route table bhi EXACT same pattern se hai