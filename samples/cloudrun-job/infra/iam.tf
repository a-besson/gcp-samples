# --- Service Account ---
resource "google_service_account" "cloudrun_sa" {
  project      = var.project_id
  account_id   = "cloudrun-job-runner${var.name_suffix}"
  display_name = "Cloud Run Job Runner"
}

# Minimal role required by the job's runtime identity: write logs to Cloud
# Logging. The image is pulled by the Cloud Run service agent, which already
# reads Artifact Registry repositories of the same project: the runtime SA
# needs no artifactregistry.reader.
resource "google_project_iam_member" "cloudrun_sa_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}
