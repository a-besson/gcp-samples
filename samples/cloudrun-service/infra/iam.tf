# --- IAM Auth ---
# No allUsers binding: authentication is mandatory.
# Access is granted via IAM roles/run.invoker on the service resource.

resource "google_cloud_run_v2_service_iam_member" "invoker" {
  location = var.region
  project  = var.project_id
  name     = google_cloud_run_v2_service.exposed_service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.exposed_service_sa.email}"
}


# Create a Test SA for authenticated calls
resource "google_service_account" "test_sa" {
  account_id   = "exp-srv-tester${var.name_suffix}"
  display_name = "Service Account for E2E Tests"
  project      = var.project_id
}

resource "google_cloud_run_v2_service_iam_member" "test_sa_invoker" {
  location = var.region
  project  = var.project_id
  name     = google_cloud_run_v2_service.exposed_service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.test_sa.email}"
}
