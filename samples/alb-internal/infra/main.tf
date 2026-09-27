# Resolves the numeric project number from project_id, needed to address
# Google-managed service agents (see iam.tf) without a redundant variable.
data "google_project" "this" {
  project_id = var.project_id
}

# --- Bootstrap stack (KMS + Artifact Registry) ---
# Read-only reference: this stack never creates or destroys the key ring/keys.
data "terraform_remote_state" "bootstrap" {
  backend = "gcs"
  config = {
    bucket = "${var.project_id}-tfstate"
    prefix = "alb-internal-bootstrap"
  }
}

# Resolves the "api:latest" tag to its current digest. Referencing the tag
# directly in cloudrun.tf would never show a Terraform diff on a new
# `task build` push (the string "api:latest" never changes) - Cloud Run
# would keep serving the old revision's image forever. Digest changes on
# every push, so Terraform always detects it and rolls a new revision.
data "google_artifact_registry_docker_image" "api" {
  project       = var.project_id
  location      = var.region
  repository_id = data.terraform_remote_state.bootstrap.outputs.artifact_repository_name
  image_name    = "api:latest"
}

locals {
  image_url = data.google_artifact_registry_docker_image.api.self_link

  # Internal-only hostnames, resolved by the private DNS zones in dns.tf.
  api_host = "api.alb-internal.internal"
}

# Enable required GCP APIs for the main stack. Overlaps with bootstrap on
# purpose: this stack must be independently re-appliable after a
# `task destroy` without re-running bootstrap.
module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.0"

  project_id                  = var.project_id
  disable_services_on_destroy = false
  activate_apis = [
    "compute.googleapis.com",
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "iap.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com", # signJwt, called locally by `task e2e` to mint the client VM's self-signed JWT
    "oslogin.googleapis.com",
    "logging.googleapis.com",    # log-based metrics on Cloud Armor denials (monitoring.tf)
    "monitoring.googleapis.com", # alert policy on Cloud Armor denials (monitoring.tf)
  ]
}
