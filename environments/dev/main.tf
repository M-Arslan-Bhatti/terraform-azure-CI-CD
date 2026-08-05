module "network" {
  source      = "../../modules/network"
  environment = var.environment
  location    = var.location
  vnet_cidr   = var.vnet_cidr
  subnets     = var.subnets
  nsg_ports   = var.nsg_ports
  extra_tags  = var.extra_tags
}