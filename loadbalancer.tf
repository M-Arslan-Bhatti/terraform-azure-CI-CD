# ═══════════════════════════════════════════════
# LAB 4 — PUBLIC IP AND LOAD BALANCER
# ═══════════════════════════════════════════════

resource "azurerm_public_ip" "lb" {
  name                = "pip-lb-${local.prefix}"
  # "pip-" = Public IP convention prefix

  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name

  allocation_method = "Static"
  # Static → IP address FIX rahega, kabhi nahi badlega
  # Options: "Static" ya "Dynamic"
  # "Dynamic" → IP badal sakta hai restart pe
  # Production mein hamesha "Static" use karo
  # Change kar sakte ho: "Dynamic" bhi try kar sakte ho
  #                      lekin Standard SKU sirf Static support karta hai

  sku = "Standard"
  # SKU → Konsa tier ka Public IP
  # Options: "Basic" ya "Standard"
  # Standard → Zone-redundant, zyada secure, LB ke saath compatible
  # Change kar sakte ho: "Basic" bhi hai lekin deprecated ho raha hai
  #                      Standard hamesha use karo

  tags = local.tags
}

resource "azurerm_lb" "app" {
  name = "lb-${local.prefix}"
  # "lb-" = Load Balancer convention

  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name

  sku = "Standard"
  # LB SKU bhi Public IP se MATCH honi chahiye
  # (Standard IP + Basic LB = ERROR aayega)

  tags = local.tags

  frontend_ip_configuration {
    # frontend_ip_configuration → LB ka "entry point"
    # Yahan se traffic LB mein aata hai

    name = "public"
    # Configuration ka naam

    public_ip_address_id = azurerm_public_ip.lb.id
    # Upar banaya Public IP se LB connect kiya
    # Dependency: Pehle IP bano, phir LB attach ho
  }
}

resource "azurerm_lb" "internal" {
  # Yeh dusra LB hai — "internal" naam se
  # Same resource type, DIFFERENT terraform name
  # Isliye alag resource banega (conflict nahi hoga)

  name                = "lb-internal-${local.prefix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  sku                 = "Standard"
  tags                = local.tags

  frontend_ip_configuration {
    name = "internal-frontend"

    subnet_id = azurerm_subnet.this["app"].id
    # YAHAN FARQ HAI upar wale LB se:
    # public_ip_address_id NAHI diya
    # Balke subnet_id diya
    # Isliye yeh koi PUBLIC IP nahi lega
    # Sirf PRIVATE IP milegi (internal traffic ke liye)

    private_ip_address_allocation = "Dynamic"
    # Private IP automatically assign ho (subnet range se)
    # Options: "Dynamic" ya "Static"
    # Change kar sakte ho: "Static" agar fixed IP chahiye
  }
}