# ═══════════════════════════════════════════════
# MODULE: budget
# Subscription-wide monthly budget + email alerts at 50/80/100%.
# ⚠️ SINGLETON: ye subscription-level resource hai (koi environment-
# specific scope nahi). Sirf EK environment (dev) se wire karo -
# agar dono dev aur qa se apply kiya to same "name" ke sath Azure
# mein "already exists" error aayega.
# ═══════════════════════════════════════════════

data "azurerm_client_config" "current" {}

resource "azurerm_consumption_budget_subscription" "monitoring" {
  name            = "budget-abc-payments-monitoring"
  subscription_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  amount          = var.budget_amount
  time_grain      = "Monthly"

  time_period {
    start_date = "2026-08-01T00:00:00Z"
    end_date   = "2036-08-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 50.0
    operator       = "GreaterThan"
    contact_emails = [var.alert_email]
  }

  notification {
    enabled        = true
    threshold      = 80.0
    operator       = "GreaterThan"
    contact_emails = [var.alert_email]
  }

  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    contact_emails = [var.alert_email]
  }
}
