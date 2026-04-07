output "service_url" {
  description = "The public URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.hello_service.uri
}

output "service_name" {
  description = "The name of the Cloud Run service"
  value       = google_cloud_run_v2_service.hello_service.name
}

output "artifact_registry_url" {
  description = "The Artifact Registry repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
}

output "curl_command" {
  description = "curl command to test the service (requires gcloud identity token)"
  value       = <<-EOT
    ID_TOKEN=$(gcloud auth print-identity-token)
    curl -i -H "Authorization: Bearer $ID_TOKEN" "${google_cloud_run_v2_service.hello_service.uri}"
  EOT
}
