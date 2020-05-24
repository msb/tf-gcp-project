# the project id
output "project_id" {
  value     = google_project.project.project_id
}

# the state bucket name
output "state_bucket_name" {
  value = google_storage_bucket.state_bucket.name
}

# the project service account credentials
output "service_account_credentials" {
  sensitive = true
  value     = "${base64decode(google_service_account_key.owner.private_key)}"
}
