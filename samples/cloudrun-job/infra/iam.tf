# --- Service Account ---
resource "google_service_account" "cloudrun_sa" {
  project      = var.project_id
  account_id   = "cloudrun-job-runner${var.name_suffix}"
  display_name = "Cloud Run Job Runner"
}

# Minimal roles required for a Cloud Run Job:
# - logWriter: write logs to Cloud Logging
# - artifactregistry.reader: pull images from Artifact Registry
resource "google_project_iam_member" "cloudrun_sa_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

resource "google_project_iam_member" "cloudrun_sa_ar_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}
