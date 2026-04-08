# --- Cloud Endpoints DNS ---
# Provides a managed .cloud.goog domain for the Load Balancer.
# This avoids manual DNS record creation and simplifies SSL provisioning.

resource "google_endpoints_service" "bastion_dns" {
  service_name = "bastion${var.name_suffix}.endpoints.${var.project_id}.cloud.goog"
  project      = var.project_id

  # Minimal OpenAPI spec to register the domain with the Load Balancer IP
  openapi_config = <<EOF
swagger: "2.0"
info:
  description: "Cloud Endpoints for Bastion"
  title: "Bastion Endpoint"
  version: "1.0.0"
host: "bastion${var.name_suffix}.endpoints.${var.project_id}.cloud.goog"
x-google-endpoints:
- name: "bastion${var.name_suffix}.endpoints.${var.project_id}.cloud.goog"
  target: "${module.lb_http.external_ip}"
paths: {}
EOF

  depends_on = [module.project_services]
}

locals {
  domain = "bastion${var.name_suffix}.endpoints.${var.project_id}.cloud.goog"
}
