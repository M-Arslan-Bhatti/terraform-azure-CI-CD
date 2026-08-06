variable "budget_amount" {
  type        = number
  description = "Monthly budget amount in USD"
}

variable "alert_email" {
  type        = string
  description = "Email address to notify at each threshold"
}
