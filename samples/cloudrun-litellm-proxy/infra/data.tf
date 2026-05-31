# Data source: read the LITELLM_MASTER_KEY from Secret Manager.
# Required by the litellm Terraform provider for API authentication.
data "google_secret_manager_secret_version" "master_key" {
  secret  = google_secret_manager_secret.master_key.secret_id
  project = var.project_id
  version = "latest"
}

# Project number — required by the billing budget filter (projects/<NUMBER>).
data "google_project" "this" {
  project_id = var.project_id
}
