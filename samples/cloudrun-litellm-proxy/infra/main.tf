module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.0"

  project_id                  = var.project_id
  disable_services_on_destroy = false
  activate_apis = [
    "run.googleapis.com",
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "aiplatform.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com",
    "dns.googleapis.com",
    "bigquery.googleapis.com",
  ]
}

data "terraform_remote_state" "base" {
  backend = "gcs"
  config = {
    bucket = "${var.project_id}-tfstate"
    prefix = "base"
  }
}

locals {
  # Derive zone DNS name and CNAME record name from var.dns_name.
  # e.g. "llm.example.com" → zone_dns = "example.com.", record_fqdn = "llm.example.com."
  dns_parts   = var.dns_name != "" ? split(".", var.dns_name) : []
  zone_dns    = var.dns_name != "" ? "${join(".", slice(local.dns_parts, 1, length(local.dns_parts)))}." : ""
  record_fqdn = var.dns_name != "" ? "${var.dns_name}." : ""
  create_dns  = var.dns_name != "" ? 1 : 0
}
