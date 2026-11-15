

# --- Service Account for Cloud Run ---
resource "google_service_account" "bastion_sa" {
  project      = var.project_id
  account_id   = "cloudrun-bastion-sa${var.name_suffix}"
  display_name = "Cloud Run Bastion Service Account"
}

# --- Allow the LB/IAP service agent to invoke Cloud Run ---
# Cloud Run ingress is restricted to INTERNAL_LOAD_BALANCER, so only the LB
# (which enforces IAP) can reach this service. allUsers here does NOT mean
# the internet can access it directly.
resource "google_cloud_run_v2_service_iam_member" "bastion_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.bastion.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
