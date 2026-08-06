Phase 4 — Manually Storage + Key Vault Banao (CLI Se, "Dekh Kar" Seekhne Ke Liye)
Resource Group
bash
az group create --name rg-terraform-state --location uksouth
Storage Account (State Ke Liye)
bash
az storage account create \
  --name sttfstateabc$RANDOM \
  --resource-group rg-terraform-state \
  --location uksouth \
  --sku Standard_LRS
Container
bash
az storage container create \
  --name tfstate \
  --account-name <upar-wala-naam> \
  --auth-mode login
Key Vault
bash
az keyvault create \
  --name kv-abc-terraform \
  --resource-group rg-terraform-state \
  --location uksouth \
  --enable-rbac-authorization true
bash
# Apne aap ko access do
MY_ID=$(az ad signed-in-user show --query id --output tsv)
az role assignment create \
  --assignee "$MY_ID" \
  --role "Key Vault Secrets Officer" \
  --scope "/subscriptions/<sub-id>/resourceGroups/rg-terraform-state/providers/Microsoft.


STEP 4 — Commands Chalane Ka Naya Tarika
bash
# ⚠️ AB terraform-labs/ SE COMMANDS NAHI CHALENGE!
# Har environment folder ke ANDAR jaake chalane hain

# DEV KE LIYE:
cd environments/dev
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
terraform destroy

# QA KE LIYE (alag terminal ya wapis root pe aake):
cd ../qa
terraform init
terraform plan
terraform apply


Command Chalane Ka Tarika Ab Badal Gaya
bash
# PURANA tarika:
cd terraform-labs/
terraform apply -var-file=environments/dev.tfvars

# NAYA tarika:
cd terraform-labs/environments/dev/
terraform init
terraform apply

Har environment folder apne aap mein independent hai — apna backend, apna state, apna "root".


# Kabhi bhi incident mein YEH commands PEHLE chalao (read-only):
terraform version
terraform workspace show
terraform state list
terraform plan -refresh-only -var-file="dev.tfvars"
az account show --query "{name:name,id:id,tenant:tenantId}"

# KABHI mat karo pressure mein:
❌ -lock=false
❌ force-unlock (bina verify kiye)
❌ terraform destroy (emergency mein)
❌ Apply karna sirf "pipeline green" karne ke liye


# State list karo to dikhega:
terraform state list

azurerm_resource_group.app
module.network.azurerm_virtual_network.spoke
module.network.azurerm_subnet.this["web"]
        ↑
   Module prefix lagta hai address mein


   Commands
bash
# List karo
terraform workspace list
# Output:
* default

# Naya workspace banao
terraform workspace new dev
terraform workspace new qa
terraform workspace new prod

# Switch karo
terraform workspace select dev

# Current dekho
terraform workspace show

# Fix — -reconfigure Use Karo

terraform init -reconfigure

terraform fmt -check -recursive
terraform validate
terraform plan -var-file=dev.tfvars

# Backend block mein directly nahi
# Sirf command-line pe per-command basis:

terraform plan -lock=false    # ⚠️ NOT RECOMMENDED