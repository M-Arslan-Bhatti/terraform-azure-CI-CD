variable "environment" {
  type = string
}

variable "location" {
  type    = string
  default = "uksouth"
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}
