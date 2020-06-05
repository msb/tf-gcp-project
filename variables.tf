# variables.tf contains definitions of variables used by the module.

variable "project_name" {}

variable "bucket_region" {
  default = "europe-west2"
}

variable "billing_account_name" {
  default = "My Billing Account"
}

variable "additional_apis" {
  default = []
}
