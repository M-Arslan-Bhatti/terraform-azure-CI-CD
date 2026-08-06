module "network" {
  source      = "../../modules/network"
  environment = var.environment
  location    = var.location
  vnet_cidr   = var.vnet_cidr
  subnets     = var.subnets
  nsg_ports   = var.nsg_ports
  extra_tags  = var.extra_tags
}

# Subscription-wide budget - sirf dev se wire kiya hai (singleton
# resource, qa se dobara apply mat karna - dekho modules/budget/main.tf)
module "budget" {
  source        = "../../modules/budget"
  budget_amount = var.budget_amount
  alert_email   = var.budget_alert_email
}