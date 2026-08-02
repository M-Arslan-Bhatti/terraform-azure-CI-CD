# ═══════════════════════════════════════════════
# DEV ENVIRONMENT VALUES
# variables.tf mein declare variables ki
# actual values yahan deti hain
# Git mein push NAHI hoti - .gitignore mein hai
# Pipeline mein manually ya secret se aati hai
# ═══════════════════════════════════════════════

# variables.tf ka "environment" variable
# locals.tf mein prefix aur tags mein use hoga
environment = "dev"

# variables.tf ka "location" variable
# Resource Group ka Azure region
location = "uksouth"

# variables.tf ka "extra_tags" variable
# map format mein - key = value
extra_tags = {
  Owner = "arslan"   # Team ya person ka naam
}

# VNet CIDR
vnet_cidr = "10.0.0.0/16"

# Subnets
subnets = {
  web  = { cidr = "10.0.1.0/24" }
  app  = { cidr = "10.0.2.0/24" }
  data = { cidr = "10.0.3.0/24" }
}