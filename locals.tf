locals {
  prefix = "abc-payments-${var.environment}-uks"

  tags = merge(var.extra_tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
    CostCenter  = "CC-4102"
  })
}
