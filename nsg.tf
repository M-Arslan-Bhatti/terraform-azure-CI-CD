# ═══════════════════════════════════════════════
# LAB 3 — NSGS (Network Security Groups)
# NSG = Firewall rules jo subnet pe lagti hain
# Priority order mein check hoti hain (kam number = pehle)
# ═══════════════════════════════════════════════

resource "azurerm_network_security_group" "web" {
  # "web" → Yeh Web tier ka NSG hai
  # Naam se hi pata chalta hai kis tier ke liye hai

  name                = "nsg-web-${local.prefix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  tags                = local.tags
  # Yeh sab pehle jaisa pattern hai

  security_rule {
    # security_rule → NESTED BLOCK hai (NSG ke andar rehta hai)
    # Ek NSG mein MULTIPLE security_rule blocks ho sakte hain
    # Har block ek RULE define karta hai

    name = "allow-https"
    # Rule ka naam - sirf identification ke liye
    # Change kar sakte ho: Haan, koi bhi naam de sakte ho

    priority = 100
    # Priority → KAUNSA RULE PEHLE CHECK HO
    # Lower number = HIGHER priority (pehle check hoga)
    # Range: 100 se 4096
    # Change kar sakte ho: Haan, lekin duplicate priority
    #                      ERROR degi (unique hona chahiye)

    direction = "Inbound"
    # Direction → Traffic kis taraf aa raha hai
    # Options: "Inbound" (aana) ya "Outbound" (jaana)
    # Change kar sakte ho: Haan, "Outbound" bhi use kar sakte ho
    #                      agar outgoing traffic control karna ho

    access = "Allow"
    # Access → Kya karna hai is traffic ka
    # Options: "Allow" (allow karo) ya "Deny" (block karo)
    # Change kar sakte ho: Haan

    protocol = "Tcp"
    # Protocol → Konsa network protocol
    # Options: "Tcp", "Udp", "Icmp", "*" (sab)
    # HTTPS/HTTP hamesha TCP use karte hain
    # Change kar sakte ho: Haan, agar UDP traffic ho to "Udp"

    source_port_range = "*"
    # Source Port → Client (browser) ka port
    # "*" matlab koi bhi port (yeh normal hai clients ke liye
    #  kyunki browser random port se connect karta hai)
    # Change kar sakte ho: Rarely, usually "*" hi rakhte hain

    destination_port_range = var.nsg_ports.https
    # Destination Port → Server ka port jahan traffic jayega
    # var.nsg_ports.https → variables.tf se, value = "443"
    # Change kar sakte ho: Haan, tfvars mein port badlo

    source_address_prefix = "Internet"
    # Source → Traffic KAHAN SE aa raha hai
    # "Internet" → Azure ka SPECIAL KEYWORD
    #              Matlab kahin se bhi internet se
    # Options: "Internet", "VirtualNetwork", "*", ya specific IP/CIDR
    # Change kar sakte ho: Haan, agar sirf specific IP allow
    #                      karni ho to CIDR daal sakte ho

    destination_address_prefix = "*"
    # Destination → Traffic KAHAN JA RAHA hai
    # "*" → Is subnet ke andar kisi bhi resource ko
    # Change kar sakte ho: Specific IP bhi de sakte ho
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 110
    # 110 > 100, isliye yeh rule HTTPS ke BAAD check hoga

    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.nsg_ports.http
    # var.nsg_ports.http = "80"

    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "deny-all-inbound"
    # Yeh "CATCH-ALL" rule hai
    # Matlab: "Jo bhi upar match nahi hua, usko BLOCK karo"

    priority = 4096
    # 4096 → MAXIMUM priority number (SABSE AAKHIR mein check hota)
    # Yeh HAMESHA sabse last rule honi chahiye
    # Change kar sakte ho: Nahi, yeh convention hai (max value)

    direction                  = "Inbound"
    access                     = "Deny"
    # Deny → Block karo!

    protocol                   = "*"
    # "*" → Sab protocols (TCP, UDP, sab kuch)

    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    # "*" → Kisi se bhi aane wala traffic

    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "web" {
  # Yeh resource NSG ko SUBNET se ATTACH karta hai
  # Bina isके, NSG bana to lega lekin kisi subnet pe LAGEGA nahi!

  subnet_id = azurerm_subnet.this["web"].id
  # azurerm_subnet.this["web"] → for_each se bana "web" subnet
  # .id → Us subnet ki Azure ID
  # Yeh DEPENDENCY create karta hai:
  # "Pehle subnet bano, phir NSG attach ho"

  network_security_group_id = azurerm_network_security_group.web.id
  # Upar bana NSG ki ID
  # Dependency: "Pehle NSG bano, phir attach ho"
}

# NOTE: app aur data NSG bhi EXACTLY isi pattern se bane hain
#       Sirf naam aur specific rules alag hain
#       (app: sirf web se allow, data: sirf app se allow)