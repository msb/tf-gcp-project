# variables.tf contains definitions of variables used by the module.

# The name of the GCP project.
variable "project_name" {}

# The region of the terraorm state bucket.
variable "bucket_region" {
  default = "europe-west2"
}

# The name of the project's billing account.
variable "billing_account_name" {
  default = "My Billing Account"
}

# GCP APIs to enable that will be needed by resources in the project
variable "additional_apis" {
  default = []
}
