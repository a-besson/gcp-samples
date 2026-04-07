# --- Static Global IP ---
resource "google_compute_global_address" "bastion_ip" {
  name    = "bastion-static-ip"
  project = var.project_id
}

# --- Backend Service ---
# IAP is enabled directly on the backend service, enforcing identity checks
# before any request reaches the Cloud Run container.
resource "google_compute_backend_service" "bastion_backend" {
  name                  = "bastion-backend"
  project               = var.project_id
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.bastion_neg.id
  }

  iap {
    enabled              = true
    oauth2_client_id     = google_iap_client.bastion_iap_client.client_id
    oauth2_client_secret = google_iap_client.bastion_iap_client.secret
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

# --- URL Map ---
resource "google_compute_url_map" "bastion_url_map" {
  name            = "bastion-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.bastion_backend.id
}

# --- Target HTTPS Proxy ---
resource "google_compute_target_https_proxy" "bastion_https_proxy" {
  name             = "bastion-https-proxy"
  project          = var.project_id
  url_map          = google_compute_url_map.bastion_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.bastion_ssl.id]
}

# --- Global Forwarding Rule ---
resource "google_compute_global_forwarding_rule" "bastion_forwarding_rule" {
  name                  = "bastion-https-forwarding-rule"
  project               = var.project_id
  ip_address            = google_compute_global_address.bastion_ip.id
  port_range            = "443"
  target                = google_compute_target_https_proxy.bastion_https_proxy.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
