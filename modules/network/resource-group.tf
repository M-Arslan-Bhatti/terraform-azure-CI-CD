resource "azurerm_resource_group" "app" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.tags
}