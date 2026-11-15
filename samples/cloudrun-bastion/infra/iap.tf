# --- IAP OAuth client ---
# No google_iap_client / google_iap_brand: the IAP OAuth Admin API behind them
# was shut down on 2026-03-19 (https://cloud.google.com/iap/docs/deprecations).
# The backend service enables IAP without a client id/secret (loadbalancer.tf),
# so IAP uses a Google-managed OAuth client: it only serves users of the
# project's organization and cannot be used programmatically
# (https://cloud.google.com/iap/docs/custom-oauth-configuration).

# --- IAP Access Binding ---
# Grants the configured user the role to pass through IAP.
# We use a count to avoid Errors (400 User not found) if the placeholder admin@example.com is used.
resource "google_iap_web_backend_service_iam_member" "bastion_iap_user" {
  count               = var.iap_user_email == "admin@example.com" ? 0 : 1
  project             = var.project_id
  web_backend_service = module.lb_http.backend_services["bastion"].name
  role                = "roles/iap.httpsResourceAccessor"
  member              = "user:${var.iap_user_email}"
}
