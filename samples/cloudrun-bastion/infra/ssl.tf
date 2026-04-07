# --- Google-Managed SSL Certificate ---
# GCP will automatically provision and renew the certificate.
# DNS A record must point var.domain to the static IP before provisioning completes.
resource "google_compute_managed_ssl_certificate" "bastion_ssl" {
  name    = "bastion-ssl-cert"
  project = var.project_id

  managed {
    domains = [var.domain]
  }
}
