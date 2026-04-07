# --- Service Account ---
resource "google_service_account" "cloudrun_sa" {
  project      = var.project_id
  account_id   = "cloudrun-job-runner"
  display_name = "Cloud Run Job Runner"
}
