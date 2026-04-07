output "job_name" {
  description = "The name of the Cloud Run Job"
  value       = google_cloud_run_v2_job.hello_job.name
}

output "artifact_registry_url" {
  description = "The Artifact Registry repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
}

output "run_job_command" {
  description = "gcloud command to manually trigger the Cloud Run Job"
  value       = "gcloud run jobs execute ${google_cloud_run_v2_job.hello_job.name} --region ${var.region} --project ${var.project_id}"
}
