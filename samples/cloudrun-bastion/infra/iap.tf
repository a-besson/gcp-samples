# --- IAP OAuth Client ---
# Using the existing project brand (only one allowed per project)
resource "google_iap_client" "bastion_iap_client" {
  display_name = "Bastion IAP Client"
  brand        = "projects/${data.google_project.this.number}/brands/${data.google_project.this.number}"
}

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
