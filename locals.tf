# ═══════════════════════════════════════════════
# LOCALS FILE
# Reusable local values yahan define hote hain
# Variables se alag - bahar se nahi aate
# Andar hi calculate hote hain
# ═══════════════════════════════════════════════

locals {

  # ═══════════════════════════════════════════
  # NAMING PREFIX
  # Har resource ka naam is prefix se banega
  # ${var.environment} runtime pe replace hoga
  #
  # dev mein  : abc-payments-dev-uks
  # prod mein : abc-payments-prod-uks
  # ═══════════════════════════════════════════
  prefix = "abc-payments-${var.environment}-uks"

  # ═══════════════════════════════════════════
  # TAGS - merge() function use ho raha hai
  # merge(map1, map2) = dono maps combine karta hai
  #
  # var.extra_tags  = { "Owner" = "arslan" }     ← bahar se
  # mandatory tags  = { "Environment" = "dev" }  ← hamesha
  #
  # Result = {
  #   Owner       = "arslan"     ← extra se
  #   Environment = "dev"        ← mandatory
  #   ManagedBy   = "Terraform"  ← mandatory
  #   CostCenter  = "CC-4102"    ← mandatory
  # }
  # ═══════════════════════════════════════════
  tags = merge(var.extra_tags, {
    Environment = var.environment  # dev / prod - dynamic
    ManagedBy   = "Terraform"      # Hamesha same - governance
    CostCenter  = "CC-4102"        # Billing tracking ke liye
  })
}