# Resolves the "bastion:latest" tag pushed by `task build` to its current
# digest (same pattern as alb-internal): the tag string never changes, so
# referencing it directly would never roll a new Cloud Run revision.
data "google_artifact_registry_docker_image" "bastion" {
  project       = var.project_id
  location      = var.region
  repository_id = data.terraform_remote_state.base.outputs.bastion_repo_name
  image_name    = "bastion:latest"
}

locals {
  bastion_image_url = data.google_artifact_registry_docker_image.bastion.self_link
}

# Resolves the numeric project number from project_id, needed to address the
# IAP service agent (see iam.tf) without a redundant input variable.
data "google_project" "this" {
  project_id = var.project_id
}

# Enable required GCP APIs
module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.0"

  project_id                  = var.project_id
  disable_services_on_destroy = false
  activate_apis = [
    "run.googleapis.com",
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "iap.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
  ]
}
