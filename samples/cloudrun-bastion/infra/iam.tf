

# --- Service Account for Cloud Run ---
resource "google_service_account" "bastion_sa" {
  project      = var.project_id
  account_id   = "cloudrun-bastion-sa${var.name_suffix}"
  display_name = "Cloud Run Bastion Service Account"
}

# --- Invocation through the LB/IAP only ---
# The INTERNAL_LOAD_BALANCER ingress also accepts requests from the project's
# VPC networks, so `allUsers` would let any VPC workload use the proxy without
# going through IAP. Only the IAP service agent, the caller Cloud Run sees once
# IAP has validated the user, may invoke the service (same pattern as
# alb-internal). The agent is normally created lazily on first use: force it,
# otherwise the binding fails with "service account does not exist" on a
# fresh project.
resource "google_project_service_identity" "iap" {
  provider   = google-beta
  project    = var.project_id
  service    = "iap.googleapis.com"
  depends_on = [module.project_services]
}

resource "google_cloud_run_v2_service_iam_member" "bastion_invoker" {
  project    = var.project_id
  location   = var.region
  name       = google_cloud_run_v2_service.bastion.name
  role       = "roles/run.invoker"
  member     = "serviceAccount:service-${data.google_project.this.number}@gcp-sa-iap.iam.gserviceaccount.com"
  depends_on = [google_project_service_identity.iap]
}
