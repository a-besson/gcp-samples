# No module covers INTERNAL_MANAGED + a serverless NEG at the regional level
# (terraform-google-modules/lb-http only targets global LBs), hence raw
# resources for the full chain below.

resource "google_compute_region_network_endpoint_group" "api" {
  name                  = "alb-internal-neg${var.name_suffix}"
  project               = var.project_id
  region                = var.region
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.api.name
  }
}

resource "google_compute_region_backend_service" "api" {
  name                  = "alb-internal-bes${var.name_suffix}"
  project               = var.project_id
  region                = var.region
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol              = "HTTP" # ignored for a serverless NEG backend, but required
  security_policy       = google_compute_region_security_policy.api.id

  # No health_checks: forbidden with a serverless NEG backend (Cloud Run
  # manages its own readiness).
  backend {
    group = google_compute_region_network_endpoint_group.api.id
  }

  # Plan.md §5 row 0: the sample's load-bearing, unconfirmed assumption —
  # IAP on a *regional* backend service backed by a *serverless NEG*. Verify
  # in isolation (`terraform apply` of this file + iap.tf alone) before
  # relying on Phase 8. Fallback: Cloud Run-native IAP, ILB kept for Cloud
  # Armor/TLS only.
  #
  # No oauth2_client_id/oauth2_client_secret: the IAP OAuth Admin API used by
  # the (now-removed) google_iap_client resource was permanently shut down
  # 2026-03-19. IAP now defaults to a Google-managed OAuth client when none
  # is configured explicitly - see iap.tf for the resulting service-account
  # self-signed-JWT access flow used by the smoke test instead of an OIDC
  # identity token scoped to a custom client_id.
  iap {
    enabled = true
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

resource "google_compute_region_url_map" "api" {
  name            = "alb-internal-urlmap${var.name_suffix}"
  project         = var.project_id
  region          = var.region
  default_service = google_compute_region_backend_service.api.id
}

# --- TLS termination ---
# Regional Google-managed certificates require Certificate Manager + a public
# DNS authorization, which is impossible for a purely internal hostname. A
# self-signed certificate is used instead; `curl -k` is required to reach the
# API. Documented in README as a "going further" item (Certificate Manager
# regional, in production).
resource "tls_private_key" "api" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "api" {
  private_key_pem = tls_private_key.api.private_key_pem

  subject {
    common_name  = local.api_host
    organization = "gcp-samples alb-internal (self-signed, internal use only)"
  }

  validity_period_hours = 8760 # 1 year
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "google_compute_region_ssl_certificate" "api" {
  name_prefix = "alb-internal-cert${var.name_suffix}-"
  project     = var.project_id
  region      = var.region
  # KICS false positive: this references the tls_private_key resource output
  # above, not a hardcoded key.
  # kics-scan ignore-line
  private_key = tls_private_key.api.private_key_pem
  certificate = tls_self_signed_cert.api.cert_pem

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_target_https_proxy" "api" {
  name             = "alb-internal-https-proxy${var.name_suffix}"
  project          = var.project_id
  region           = var.region
  url_map          = google_compute_region_url_map.api.id
  ssl_certificates = [google_compute_region_ssl_certificate.api.id]
}

resource "google_compute_forwarding_rule" "api" {
  name                  = "alb-internal-fr${var.name_suffix}"
  project               = var.project_id
  region                = var.region
  load_balancing_scheme = "INTERNAL_MANAGED"
  network               = google_compute_network.vpc.id
  subnetwork            = google_compute_subnetwork.isolated.id # VIP in subnet-isolated, not the proxy-only subnet
  target                = google_compute_region_target_https_proxy.api.id
  port_range            = "443" # target_https_proxy takes port_range, not ports (that field is for backend_service-targeted internal LBs)
  network_tier          = "PREMIUM"
  depends_on            = [google_compute_subnetwork.proxy_only]
}

# --- Private DNS for the API hostname ---
resource "google_dns_managed_zone" "api" {
  name       = "alb-internal-api${var.name_suffix}"
  project    = var.project_id
  dns_name   = "alb-internal.internal."
  visibility = "private"
  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc.id
    }
  }
}

resource "google_dns_record_set" "api" {
  name         = "${local.api_host}."
  managed_zone = google_dns_managed_zone.api.name
  project      = var.project_id
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_forwarding_rule.api.ip_address]
}
