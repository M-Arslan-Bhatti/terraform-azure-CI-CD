resource "azurerm_public_ip" "appgw" {
  name                = "pip-appgw-${local.prefix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_web_application_firewall_policy" "portal" {
  name                = "wafpolicy-${local.prefix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  tags                = local.tags

  policy_settings {
    enabled                     = true
    mode                        = "Detection"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

resource "azurerm_application_gateway" "portal" {
  name                = "agw-${local.prefix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  tags                = local.tags

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.portal.id

  autoscale_configuration {
    min_capacity = 2
    max_capacity = 6
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.this["appgw"].id
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  frontend_port {
    name = "port-80"
    port = 80
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "listener-80"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule-basic"
    rule_type                  = "Basic"
    http_listener_name         = "listener-80"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 100
  }
}