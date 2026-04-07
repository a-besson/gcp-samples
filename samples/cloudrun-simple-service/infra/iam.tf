# --- Service Account ---
resource "google_service_account" "cloudrun_sa" {
  project      = var.project_id
  account_id   = "cloudrun-service-runner"
  display_name = "Cloud Run Service Runner"
}

# --- IAM: allow authenticated users to invoke the service ---
resource "google_cloud_run_v2_service_iam_member" "invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.hello_service.name
  role     = "roles/run.invoker"
  member   = "allAuthenticatedUsers"
}
