# ═══════════════════════════════════════════════
# LAB 1 — RESOURCE GROUPS, NAMING AND TAGS
# Yeh file Resource Group banati hai
# Resource Group = Azure ka container/boundary
# ═══════════════════════════════════════════════

resource "azurerm_resource_group" "app" {
  # "azurerm_resource_group" → Yeh Azure Provider ka resource TYPE hai
  #                             Fixed hai, badal nahi sakte
  #                             (AzureRM provider isi naam se pehchanta hai)
  #
  # "app" → Yeh HUMARA diya hua LOCAL NAME hai (Terraform address ke liye)
  #         Badal sakte ho, lekin badalne se Terraform
  #         PURANA resource DELETE karega, NAYA banayega!
  #         Isliye ek baar decide karke fix rakho

  name = "rg-${local.prefix}"
  # name → Azure mein ACTUAL naam jo dikhega Portal mein
  # "rg-" → Humne prefix diya (convention: rg = resource group)
  # ${local.prefix} → locals.tf se aata hai
  #                   = "abc-payments-dev-uks"
  # Final Result: "rg-abc-payments-dev-uks"
  # Change kar sakte ho: Haan, lekin naam badalne se
  #                      Azure mein RENAME nahi hota,
  #                      PURANA delete, NAYA create hota hai!

  location = var.location
  # location → Kahan banega (Azure Region)
  # var.location → variables.tf se declare hua
  #                dev.tfvars se value aati hai: "uksouth"
  # Change kar sakte ho: Haan, tfvars mein value badal do
  #                      Lekin location badalne se resource
  #                      REPLACE hoga (destroy + recreate)!

  tags = local.tags
  # tags → Metadata jo Azure resource pe lagta hai
  # local.tags → locals.tf se aata hai (merge() se bana)
  #              = { Environment, ManagedBy, CostCenter, Owner }
  # Change kar sakte ho: Haan, tags change karna SAFE hai
  #                      Koi replacement nahi hota, sirf update hota hai
}