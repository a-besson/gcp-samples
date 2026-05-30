# Runtime Service Account — least-privilege identity for the LiteLLM container
# and the Cloud SQL Auth Proxy sidecar.
resource "google_service_account" "litellm_runner" {
  account_id   = "litellm-runner${var.name_suffix}"
  display_name = "LiteLLM Cloud Run runtime SA"
  project      = var.project_id
}

resource "google_project_iam_member" "runner_vertex_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.litellm_runner.email}"
}

resource "google_project_iam_member" "runner_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.litellm_runner.email}"
}

resource "google_project_iam_member" "runner_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.litellm_runner.email}"
}

# Cloud SQL Auth Proxy: `cloudsql.client` to open IAM-authenticated tunnels,
# and `cloudsql.instanceUser` to support IAM DB authentication (iam_authentication flag).
resource "google_project_iam_member" "runner_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.litellm_runner.email}"
}

resource "google_project_iam_member" "runner_cloudsql_instance_user" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = "serviceAccount:${google_service_account.litellm_runner.email}"
}

resource "google_secret_manager_secret_iam_member" "runner_master_key" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.master_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.litellm_runner.email}"
}

resource "google_secret_manager_secret_iam_member" "runner_database_url" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.database_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.litellm_runner.email}"
}

# BigQuery: write observability logs (tokens, cost, latency) from LiteLLM callback.
resource "google_bigquery_dataset_iam_member" "runner_bq_editor" {
  dataset_id = google_bigquery_dataset.litellm.dataset_id
  project    = var.project_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.litellm_runner.email}"
}

resource "google_project_iam_member" "runner_bq_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.litellm_runner.email}"
}

# Security Design — Two-layer authentication model:
#   Layer 1 (Network): Cloud Run is publicly reachable (allUsers invoker) so that
#     standard OpenAI SDK clients can connect without a GCP identity. The Google
#     Frontend (GFE) strips standard `Authorization: Bearer` headers, so using
#     a custom `x-api-key` header bypasses GFE interception.
#   Layer 2 (Application): Every request MUST carry a valid LiteLLM Virtual Key
#     in `x-api-key: Bearer sk-...`. The proxy rejects unauthenticated requests
#     at the application level (middleware: litellm_key_header_name).
# This design intentionally trades Cloud Run IAM auth for application-level auth
# to remain compatible with standard OpenAI SDK clients (no GCP token required).
resource "google_cloud_run_v2_service_iam_member" "invoker" {
  location = var.region
  project  = var.project_id
  name     = google_cloud_run_v2_service.litellm.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

