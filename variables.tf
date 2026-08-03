# ═══════════════════════════════════════════════
# VARIABLES FILE
# Saare input variables yahan declare hote hain
# Values bahar se aati hain - tfvars se
# ═══════════════════════════════════════════════

# Environment variable
# Kaunsa environment hai - dev, qa, prod
# Pipeline mein alag alag tfvars se aata hai
variable "environment" {
  type        = string              # Sirf string accept karega
  description = "Environment name" # Documentation ke liye
                                   # dev / qa / uat / prod
}

# Azure Region variable
# Kahan deploy karna hai
# Default uksouth - ABC Bank UK mein hai
variable "location" {
  type        = string
  description = "Azure region location"
  default     = "uksouth"          # Agar tfvars mein na ho
                                   # to yeh value use hogi
}

# Extra Tags variable
# Additional tags jo specific environment mein chahiye
# map(string) = key value pairs
# { "Owner" = "arslan", "Team" = "devops" }
variable "extra_tags" {
  type        = map(string)
  description = "Additional tags to merge"
  default     = {}                 # Default empty map
                                   # Optional variable hai
}

# ═══════════════════════════════════════════════
# EXISTING CODE UPAR HAI - YAHAN SE NAYA ADD KAO
# ═══════════════════════════════════════════════

# VNet CIDR variable
# Poora network range
variable "vnet_cidr" {
  type        = string
  description = "VNet address space"
  default     = "10.0.0.0/16"
}

# Subnets variable
# Map of subnets - naam aur CIDR
variable "subnets" {
  type = map(object({
    cidr = string
  }))
  description = "Subnets to create in VNet"
  default = {
    web  = { cidr = "10.0.1.0/24" }
    app  = { cidr = "10.0.2.0/24" }
    data = { cidr = "10.0.3.0/24" }
  }
}

# ═══════════════════════════════════════════════
# LAB 3 — NSG PORTS VARIABLE
# Environment-dependent port numbers
# dev/qa/prod mein alag ho sakte hain
# ═══════════════════════════════════════════════
variable "nsg_ports" {
  type = object({
    https = string   # Web tier - HTTPS traffic
    http  = string   # Web tier - HTTP traffic
    app   = string   # App tier - Application port
    db    = string   # Data tier - Database port
  })
  description = "NSG port numbers for each tier"
  default = {
    https = "443"    # Standard HTTPS
    http  = "80"     # Standard HTTP
    app   = "8080"   # Common app port
    db    = "1433"   # SQL Server default port
  }
}
