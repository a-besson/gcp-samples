# --- Global HTTPS Load Balancer ---
# Exposes the Cloud Run service via a Serverless Network Endpoint Group (NEG)
# Reference: https://github.com/terraform-google-modules/terraform-google-lb-http/tree/main/modules/serverless_negs

module "lb_http" {
  source  = "terraform-google-modules/lb-http/google//modules/serverless_negs"
  version = "~> 14.0"

  name    = "exposed-service-lb${var.name_suffix}"
  project = var.project_id

  # HTTPS only, with a Google-managed certificate on the Cloud Endpoints
  # domain (dns.tf): callers send identity tokens, which must never travel
  # over plain HTTP. No port 80 listener at all (no redirect either).
  ssl                             = true
  managed_ssl_certificate_domains = [local.domain]
  https_redirect                  = false
  http_forward                    = false

  backends = {
    default = {
      description = "Serverless NEG for Cloud Run exposed-service"
      groups      = []
      serverless_neg_backends = [
        {
          region = var.region
          type   = "cloud-run"
          service = {
            name = google_cloud_run_v2_service.exposed_service.name
          }
        }
      ]
      enable_cdn = false

      iap_config = {
        enable = false
      }
      log_config = {
        enable = true
      }
    }
  }
}
