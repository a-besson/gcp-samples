# --- Global HTTP Load Balancer ---
# Exposes the Cloud Run bastion via a Serverless Network Endpoint Group (NEG)
# Reference: https://github.com/terraform-google-modules/terraform-google-lb-http/tree/main/modules/serverless_negs

module "lb_http" {
  source  = "terraform-google-modules/lb-http/google//modules/serverless_negs"
  version = "~> 14.0"

  name    = "bastion-lb${var.name_suffix}"
  project = var.project_id

  # SSL/DNS handled via Cloud Endpoints (see dns.tf) or custom domain
  ssl                             = true
  managed_ssl_certificate_domains = [local.domain]
  https_redirect                  = true

  backends = {
    bastion = {
      description = "Serverless NEG for Cloud Run bastion"
      groups      = []
      serverless_neg_backends = [
        {
          region = var.region
          type   = "cloud-run"
          service = {
            name = google_cloud_run_v2_service.bastion.name
          }
        }
      ]
      enable_cdn = false

      iap_config = {
        enable               = true
        oauth2_client_id     = google_iap_client.bastion_iap_client.client_id
        oauth2_client_secret = google_iap_client.bastion_iap_client.secret
      }
      log_config = {
        enable      = true
        sample_rate = 1.0
      }
    }
  }
}
