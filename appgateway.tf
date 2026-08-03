# ═══════════════════════════════════════════════
# LAB 5 — APPLICATION GATEWAY AND WAF
# Layer 7 Load Balancer + Web Firewall
# ═══════════════════════════════════════════════

resource "azurerm_public_ip" "appgw" {
  name                = "pip-appgw-${local.prefix}"
  # App Gateway ka apna ALAG Public IP
  # (LB wali IP se conflict nahi hoga - alag naam hai)

  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_application_gateway" "portal" {
  name = "agw-${local.prefix}"
  # "agw-" = Application Gateway convention

  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  tags                = local.tags

  sku {
    # sku → NESTED BLOCK, App Gateway ka tier define karta hai

    name = "WAF_v2"
    # WAF_v2 → Web Application Firewall version 2
    # Options: "Standard_v2" (bina WAF) ya "WAF_v2" (WAF ke saath)
    # Change kar sakte ho: "Standard_v2" agar security
    #                      abhi nahi chahiye (sasta hai thoda)

    tier = "WAF_v2"
    # Tier bhi same match karni hoti hai name ke sath
  }

  autoscale_configuration {
    # Autoscale → Traffic badhne pe automatically
    #             instances badha deta hai

    min_capacity = 2
    # Minimum 2 instances HAMESHA chalte rahenge
    # (Yeh MINIMUM COST determine karta hai)
    # Change kar sakte ho: Minimum 0 tak nahi kar sakte,
    #                      WAF_v2 ke liye kam se kam ek chahiye

    max_capacity = 6
    # Maximum 6 tak scale ho sakta hai heavy traffic mein
    # Change kar sakte ho: Zyada bhi rakh sakte ho
    #                      (zyada max = zyada max possible cost)
  }

  gateway_ip_configuration {
    # App Gateway ka APNA DEDICATED subnet chahiye
    # (Shared subnet use nahi kar sakta doosre resources ke saath)

    name = "gateway-ip-config"

    subnet_id = azurerm_subnet.this["appgw"].id
    # "appgw" subnet jo humne variables.tf mein add kiya tha
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw.id
    # Upar banaya IP se connect
  }

  frontend_port {
    # Frontend Port → Kaunsa port SUNNA hai (users se)

    name = "port-80"
    port = 80
    # Abhi HTTP (80) use kiya testing ke liye
    # Production mein 443 (HTTPS) use karenge with SSL cert
    # Change kar sakte ho: 443 bhi add kar sakte ho
    #                      (SSL certificate ke saath)
  }

  backend_address_pool {
    # Backend Pool → JAHAN traffic FORWARD hoga
    # Abhi EMPTY hai (koi VM/server nahi hai)
    # Baad mein VM banayenge to yahan add karenge

    name = "backend-pool"
  }

  backend_http_settings {
    # Backend se KAISE baat karni hai (App Gateway → Backend)

    name = "http-settings"

    cookie_based_affinity = "Disabled"
    # Session stickiness (same user same server pe jaye ya nahi)
    # Options: "Enabled" ya "Disabled"
    # Change kar sakte ho: "Enabled" agar session data
    #                      ek hi server pe rakhni ho

    port     = 80
    protocol = "Http"
    # Backend se HTTP pe baat karega
    # Change kar sakte ho: "Https" agar backend bhi SSL use kare

    request_timeout = 20
    # 20 seconds tak wait karega response ke liye
    # Change kar sakte ho: Zyada/kam kar sakte ho (1-86400 seconds)
  }

  http_listener {
    # Listener → Kaunsa PORT + IP combination SUNE

    name                           = "listener-80"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "port-80"
    # Upar define kiye components ko REFERENCE kiya (by name, string se)
    # NOTE: Yahan .id nahi, seedha NAME string diya hai
    #       (App Gateway ka apna internal referencing system hai)

    protocol = "Http"
  }

  request_routing_rule {
    # Yeh sab kuch CONNECT karta hai:
    # "Is Listener pe traffic aaye to Backend Pool ko bhejo,
    #  in HTTP Settings ke saath"

    name      = "routing-rule-basic"
    rule_type = "Basic"
    # "Basic" → Simple routing (sab traffic ek hi backend)
    # "PathBasedRouting" → URL path ke hisab se alag backend
    # Change kar sakte ho: "PathBasedRouting" jab multiple
    #                      backends honge (/login, /payment, etc)

    http_listener_name         = "listener-80"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
    # Sab upar define kiye names se reference

    priority = 100
    # Priority - agar multiple rules hon to konsi pehle check ho
  }
}