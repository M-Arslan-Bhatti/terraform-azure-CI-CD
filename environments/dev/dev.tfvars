environment = "dev"
location    = "uksouth"
vnet_cidr   = "10.1.0.0/16"

subnets = {
  web  = { cidr = "10.1.1.0/24" }
  app  = { cidr = "10.1.2.0/24" }
  data = { cidr = "10.1.3.0/24" }
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

budget_amount      = 20
budget_alert_email = "muhammadarslan196196@gmail.com"