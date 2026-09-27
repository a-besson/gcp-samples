# --- IAP access bindings ---
# No `google_iap_client` / custom OAuth client here: the IAP OAuth Admin API
# it depends on was permanently shut down 2026-03-19 (deprecated since
# 2025-01-22). IAP now falls back to a Google-managed OAuth client whenever
# `iap { enabled = true }` omits oauth2_client_id/oauth2_client_secret (see
# loadbalancer.tf). The Google-managed client cannot mint OIDC identity
# tokens for programmatic access, so the smoke test instead uses a
# self-signed service-account JWT (`aud` = the API URL) signed via the IAM
# Credentials API — see client_vm.tf / Taskfile.yml `e2e` task.
#
# Guarded with `count` against the placeholder admin@example.com, to avoid a
# 400 "user not found" on a first plan with the default .env.example value.
resource "google_iap_web_region_backend_service_iam_member" "user_access" {
  count                      = var.iap_user_email == "admin@example.com" ? 0 : 1
  project                    = var.project_id
  region                     = var.region
  web_region_backend_service = google_compute_region_backend_service.api.name
  role                       = "roles/iap.httpsResourceAccessor"
  member                     = "user:${var.iap_user_email}"
}

resource "google_iap_web_region_backend_service_iam_member" "client_vm_access" {
  project                    = var.project_id
  region                     = var.region
  web_region_backend_service = google_compute_region_backend_service.api.name
  role                       = "roles/iap.httpsResourceAccessor"
  member                     = "serviceAccount:${google_service_account.client_vm.email}"
}

# SSH into the client VM via the IAP TCP tunnel (gcloud compute ssh
# --tunnel-through-iap) - a separate permission from HTTPS resource access.
resource "google_project_iam_member" "iap_tunnel_user" {
  count   = var.iap_user_email == "admin@example.com" ? 0 : 1
  project = var.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "user:${var.iap_user_email}"
}
