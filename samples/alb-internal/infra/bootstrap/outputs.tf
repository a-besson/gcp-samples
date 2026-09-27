output "kms_key_sql" {
  description = "CMEK key ID for Cloud SQL disk/backup encryption."
  value       = google_kms_crypto_key.keys["sql"].id
}

output "kms_key_run" {
  description = "CMEK key ID for the Cloud Run service."
  value       = google_kms_crypto_key.keys["run"].id
}

output "kms_key_secrets" {
  description = "CMEK key ID for Secret Manager secret replication."
  value       = google_kms_crypto_key.keys["secrets"].id
}

output "kms_key_compute" {
  description = "CMEK key ID for the client VM boot disk."
  value       = google_kms_crypto_key.keys["compute"].id
}

output "kms_key_ring_id" {
  description = "The KMS key ring ID, for reference/debugging."
  value       = google_kms_key_ring.main.id
}

output "artifact_repository_name" {
  description = "Artifact Registry repository name (used to build the image URL)."
  value       = google_artifact_registry_repository.api.repository_id
}

output "artifact_repository_url" {
  description = "Full Artifact Registry repository URL."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.api.repository_id}"
}
