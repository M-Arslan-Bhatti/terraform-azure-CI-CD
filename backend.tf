# ═══════════════════════════════════════════════
# BACKEND FILE
# Remote State — Azure Storage Account mein
# State file yahan store hoti hai, local nahi
# ═══════════════════════════════════════════════
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "starslanterraform001"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}