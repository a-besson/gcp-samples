# --- IAP OAuth Brand ---
# An IAP brand represents the OAuth consent screen. Only one brand per project.
resource "google_iap_brand" "bastion_brand" {
  project           = var.project_id
  support_email     = var.support_email
  application_title = "Cloud Run Bastion"

  depends_on = [module.project_services]
}

# --- IAP OAuth Client ---
resource "google_iap_client" "bastion_iap_client" {
  display_name = "Bastion IAP Client"
  brand        = google_iap_brand.bastion_brand.name
}

# --- IAP Access Binding ---
# Grants the configured user the role to pass through IAP.
resource "google_iap_web_backend_service_iam_member" "bastion_iap_user" {
  project             = var.project_id
  web_backend_service = google_compute_backend_service.bastion_backend.name
  role                = "roles/iap.httpsResourceAccessor"
  member              = "user:${var.iap_user_email}"
}
