# Use the default trial billing account name unless one has been specified
data "google_billing_account" "acct" {
  display_name = lookup(local.overrides, "billing_account_name", "My Billing Account")
  open         = true
}

# The project id -  a slug of `project_name` and a random token
resource "random_id" "project_id" {
  byte_length = 3
  prefix      = "${replace(trimspace(lower(substr(local.project_name, 0, 23))), "/[^a-z0-9]+/", "-")}-"
}

# A project linked to the defined billing account
resource "google_project" "project" {
  name            = local.project_name
  project_id      = random_id.project_id.hex
  billing_account = data.google_billing_account.acct.id
}

# A delay of 1 minute while project creation comes through the pipes
# [TODO: this can be removed in v3.23.0](https://github.com/terraform-providers/terraform-provider-google/issues/6377)
resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 60"
  }
  triggers = {
    "project" = "${google_project.project.id}"
  }
}

# Enable cloudresourcemanager API for the project service account
resource "google_project_service" "cloudresourcemanager_api" {
  project = google_project.project.project_id
  service = "cloudresourcemanager.googleapis.com"
}

locals {
  additional_apis = lookup(local.overrides, "additional_apis", [])
}

# Enable additional API's required for other project resources
# (the project service account doesn't seem to have permission)
resource "google_project_service" "additional_apis" {
  count   = length(local.additional_apis)
  project = google_project.project.project_id
  service = local.additional_apis[count.index]
}

# The name of the state bucket
resource "random_id" "state_bucket" {
  byte_length = 3
  prefix      = "terraform-state-"
}

# A storage bucket to store subsequent TF resource state
resource "google_storage_bucket" "state_bucket" {
  project  = google_project.project.project_id
  name     = random_id.state_bucket.hex
  location = lookup(local.overrides, "bucket_region", "europe-west2")

  versioning {
    enabled = true
  }
}

# The main project service account (used when creating further project resources)
resource "google_service_account" "owner" {
  project      = google_project.project.project_id
  account_id   = "terraform-admin"
  display_name = "Project Scoped Terraform Service Account"
  depends_on = [null_resource.delay]
}

# The project service account must have the "roles/owner" role.
resource "google_project_iam_member" "owner" {
  project = google_project.project.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.owner.email}"
}

# A key which can be used to authenticate as the project service account.
resource "google_service_account_key" "owner" {
  service_account_id = google_service_account.owner.name
}
