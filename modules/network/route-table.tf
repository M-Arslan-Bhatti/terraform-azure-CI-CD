resource "azurerm_route_table" "app" {
  name                = "rt-app-${local.prefix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  tags                = local.tags

  route {
    name           = "default-route"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "app" {
  subnet_id      = azurerm_subnet.this["app"].id
  route_table_id = azurerm_route_table.app.id
}

resource "azurerm_route_table" "data" {
  name                = "rt-data-${local.prefix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  tags                = local.tags

  route {
    name           = "default-route"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "data" {
  subnet_id      = azurerm_subnet.this["data"].id
  route_table_id = azurerm_route_table.data.id
}