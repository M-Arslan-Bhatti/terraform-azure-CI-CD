environment = "qa"
location    = "uksouth"
vnet_cidr   = "10.2.0.0/16"

subnets = {
  web  = { cidr = "10.2.1.0/24" }
  app  = { cidr = "10.2.2.0/24" }
  data = { cidr = "10.2.3.0/24" }
}

nsg_ports = {
  https = "443"
  http  = "80"
  app   = "8080"
  db    = "1433"
}

extra_tags = {
  Owner = "arslan"
}