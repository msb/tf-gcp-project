output "project_id" {
  value       = google_project.project.project_id
  description = "The GCP project's id."
}

output "state_bucket_name" {
  value = google_storage_bucket.state_bucket.name
  description = "The name of the bucket for terraform state."
}

output "service_account_credentials" {
  sensitive = true
  value     = "${base64decode(google_service_account_key.owner.private_key)}"
  description = "The project service account credentials."
}
