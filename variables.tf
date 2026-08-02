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