resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-${local.prefix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  address_space       = [var.vnet_cidr]
  tags                = local.tags
}

resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = contains(["AzureBastionSubnet", "AzureFirewallSubnet"], each.key) ? each.key : "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.app.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [each.value.cidr]
}