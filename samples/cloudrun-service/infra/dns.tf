# --- Cloud Endpoints DNS ---
# Provides a managed .cloud.goog domain for the Load Balancer, so that it can
# serve HTTPS with a Google-managed certificate (same pattern as
# cloudrun-bastion): identity tokens never cross the internet in clear text.

resource "google_endpoints_service" "lb_dns" {
  service_name = local.domain
  project      = var.project_id

  # Minimal OpenAPI spec to register the domain with the Load Balancer IP
  openapi_config = <<EOT
swagger: "2.0"
info:
  description: "Cloud Endpoints for exposed-service"
  title: "Exposed Service Endpoint"
  version: "1.0.0"
host: "${local.domain}"
x-google-endpoints:
- name: "${local.domain}"
  target: "${module.lb_http.external_ip}"
paths: {}
EOT

  depends_on = [module.project_services]
}

locals {
  domain = "exposed-service${var.name_suffix}.endpoints.${var.project_id}.cloud.goog"
}
