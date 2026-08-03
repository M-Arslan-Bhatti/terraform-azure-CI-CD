# ═══════════════════════════════════════════════
# LAB 2 — VIRTUAL NETWORKS AND SUBNETS
# VNet = Private network space
# Subnet = VNet ke andar chote chote zones
# ═══════════════════════════════════════════════

resource "azurerm_virtual_network" "spoke" {
  # "azurerm_virtual_network" → Fixed Azure resource type
  # "spoke" → Humara diya naam (Hub-Spoke architecture se liya
  #           kyunki yeh "Spoke" VNet hai, Hub nahi)
  #           Change kar sakte ho lekin resource replace hoga

  name = "vnet-${local.prefix}"
  # "vnet-" prefix + local.prefix
  # Result: "vnet-abc-payments-dev-uks"
  # Change kar sakte ho: Haan, replacement hoga

  location = azurerm_resource_group.app.location
  # YAHAN IMPORTANT HAI:
  # var.location SEEDHA use nahi kiya
  # Balke azurerm_resource_group.app.location use kiya
  #
  # Kyun? DEPENDENCY banane ke liye!
  # Terraform samjhega: "Pehle Resource Group banao,
  #                      phir uski location se VNet banao"
  # Yeh best practice hai — resource-to-resource reference
  # Change kar sakte ho: Nahi recommend karta, yeh best practice hai

  resource_group_name = azurerm_resource_group.app.name
  # Same logic — RG ka naam directly reference kiya
  # Isse dependency graph banta hai automatically
  # Change kar sakte ho: Nahi, yeh dependency ke liye zaroori hai

  address_space = [var.vnet_cidr]
  # address_space → LIST hona chahiye (isliye [ ] brackets)
  # var.vnet_cidr → variables.tf se, default "10.0.0.0/16"
  # Change kar sakte ho: Haan, tfvars mein value badlo
  #                      CIDR badalne se VNet REPLACE hoga
  #                      (sab subnets bhi delete-recreate!)

  tags = local.tags
  # Same jaise Resource Group mein
}

resource "azurerm_subnet" "this" {
  # "azurerm_subnet" → Fixed Azure resource type
  # "this" → Generic naam (kyunki for_each use ho raha hai,
  #          multiple subnets isi block se bante hain)
  # Change kar sakte ho: Haan lekin "this" convention hai
  #                      for_each resources ke liye

  for_each = var.subnets
  # for_each → LOOP hai! Har entry ke liye ek subnet banega
  # var.subnets → Map hai: { web = {...}, app = {...}, data = {...} }
  # Result: 3 subnets automatically ban jayenge
  # Change kar sakte ho: Haan, tfvars mein naya subnet add karo
  #                      → automatically naya subnet ban jayega!

  name = "snet-${each.key}"
  # each.key → Loop ka current KEY (web / app / data)
  # "snet-" + each.key
  # Result: snet-web, snet-app, snet-data
  # Change kar sakte ho: Naam convention badal sakte ho

  resource_group_name = azurerm_resource_group.app.name
  # Dependency - RG ke andar banega

  virtual_network_name = azurerm_virtual_network.spoke.name
  # Dependency - Is VNet ke andar banega
  # Yeh IMPORTANT hai — batata hai subnet KAHAN belong karta hai

  address_prefixes = [each.value.cidr]
  # each.value → Loop ka current VALUE (object)
  # each.value.cidr → Us object ka cidr field
  # Example: web ke liye → "10.0.1.0/24"
  # LIST honi chahiye isliye [ ] brackets
  # Change kar sakte ho: Haan, tfvars mein CIDR badlo
}