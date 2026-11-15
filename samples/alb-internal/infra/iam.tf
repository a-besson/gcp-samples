# --- Cloud Run API service account ---
resource "google_service_account" "api" {
  project      = var.project_id
  account_id   = "alb-internal-api${var.name_suffix}"
  display_name = "alb-internal API (Cloud Run runtime)"

  depends_on = [module.project_services]
}

resource "google_project_iam_member" "api_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.api.email}"
}

resource "google_project_iam_member" "api_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.api.email}"
}

resource "google_project_iam_member" "api_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.api.email}"
}

# Least privilege: bound to the single secret, never roles/secretmanager.*
# at the project level.
resource "google_secret_manager_secret_iam_member" "api_secret_accessor" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.api.email}"
}

# --- Client VM service account ---
# No project-level IAM role is granted here on purpose: see the firewall.tf
# deny-all-egress note — a granted role the VM cannot reach through the
# network (e.g. roles/logging.logWriter, blocked since only the metadata
# server and the ILB CIDR are allowed egress) would be dishonest. Its only
# permission is roles/iap.httpsResourceAccessor, granted in iap.tf.
resource "google_service_account" "client_vm" {
  project      = var.project_id
  account_id   = "alb-internal-client${var.name_suffix}"
  display_name = "alb-internal client VM (smoke test)"

  depends_on = [module.project_services]
}

# Lets the operator (running `task e2e` locally, with their own gcloud
# ADC) call IAM Credentials API signJwt on the client VM's service account,
# to produce the self-signed JWT the smoke test presents to IAP
# (Google-managed OAuth client path - see iap.tf). Signing happens on the
# operator's machine, never on the VM itself: the VM's deny-all-egress
# firewall (firewall.tf) blocks real calls to iamcredentials.googleapis.com,
# so only a caller with real Internet egress can mint the JWT. The VM then
# only presents the pre-signed JWT to the ILB - see Taskfile.yml `e2e`.
resource "google_service_account_iam_member" "operator_token_creator" {
  count              = var.iap_user_email == "admin@example.com" ? 0 : 1
  service_account_id = google_service_account.client_vm.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "user:${var.iap_user_email}"
}

# --- Invocation via the ILB/IAP ---
# The IAP service agent is normally created lazily on first use: force it
# up front, same pattern as infra/bootstrap/main.tf for its own agents,
# otherwise the IAM binding below fails with "service account does not
# exist" on a fresh project.
resource "google_project_service_identity" "iap" {
  provider   = google-beta
  project    = var.project_id
  service    = "iap.googleapis.com"
  depends_on = [module.project_services]
}

# The IAP service agent is the caller Cloud Run actually sees once IAP has
# validated the end user's identity (row 3, plan.md §5): least-privilege
# alternative to `allUsers` (cloudrun-bastion uses the same binding on its
# *global* backend service). If IAP on a regional backend
# service backed by a serverless NEG turns out unsupported (plan.md §5 row 0)
# and the sample falls back to Cloud Run-native IAP, this binding target
# changes to the IAP-P4SA and the `iap {}` block moves off the backend
# service — see plan.md for that decision tree.
resource "google_cloud_run_v2_service_iam_member" "iap_invoker" {
  project    = var.project_id
  location   = var.region
  name       = google_cloud_run_v2_service.api.name
  role       = "roles/run.invoker"
  member     = "serviceAccount:service-${data.google_project.this.number}@gcp-sa-iap.iam.gserviceaccount.com"
  depends_on = [google_project_service_identity.iap]
}
