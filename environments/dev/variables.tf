variable "environment" {
  type        = string
  description = "Environment name"
}

variable "location" {
  type    = string
  default = "uksouth"
}

variable "vnet_cidr" {
  type        = string
  description = "VNet address space"
}

variable "subnets" {
  type = map(object({
    cidr = string
  }))
}

variable "nsg_ports" {
  type = object({
    https = string
    http  = string
    app   = string
    db    = string
  })
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}