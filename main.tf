# Use the default trial billing account name unless one has been specified
data "google_billing_account" "acct" {
  display_name = var.billing_account_name
  open         = true
}

# The project id -  a slug of `project_name` and a random token
resource "random_id" "project_id" {
  byte_length = 3
  prefix      = "${replace(trimspace(lower(substr(var.project_name, 0, 23))), "/[^a-z0-9]+/", "-")}-"
}

# A project linked to the defined billing account
resource "google_project" "project" {
  name            = var.project_name
  project_id      = random_id.project_id.hex
  billing_account = data.google_billing_account.acct.id
}

# Enable cloudresourcemanager API for the project service account
resource "google_project_service" "cloudresourcemanager_api" {
  project = google_project.project.project_id
  service = "cloudresourcemanager.googleapis.com"
}

# Enable additional API's required for other project resources
# (the project service account doesn't seem to have permission)
resource "google_project_service" "additional_apis" {
  count   = length(var.additional_apis)
  project = google_project.project.project_id
  service = var.additional_apis[count.index]
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
  location = var.bucket_region

  versioning {
    enabled = true
  }
}

# The main project service account (used when creating further project resources)
resource "google_service_account" "owner" {
  project      = google_project.project.project_id
  account_id   = "terraform-admin"
  display_name = "Project Scoped Terraform Service Account"
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
