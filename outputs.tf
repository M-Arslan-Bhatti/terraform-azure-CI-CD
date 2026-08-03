# ═══════════════════════════════════════════════
# OUTPUTS FILE
# Deployment ke baad important values dikhata hai
# Team/Pipeline ke liye useful hai
# ═══════════════════════════════════════════════

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.app.name
}

output "resource_group_id" {
  description = "Resource ID of the resource group"
  value       = azurerm_resource_group.app.id
}

output "vnet_id" {
  description = "Created VNet resource ID"
  value       = azurerm_virtual_network.spoke.id
}

output "vnet_name" {
  description = "Created VNet name"
  value       = azurerm_virtual_network.spoke.name
}

output "subnet_ids" {
  description = "Map of subnet names to their resource IDs"
  value       = { for k, v in azurerm_subnet.this : k => v.id }
}

output "load_balancer_public_ip" {
  description = "Public IP address of the main load balancer"
  value       = azurerm_public_ip.lb.ip_address
}

output "app_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.appgw.ip_address
}