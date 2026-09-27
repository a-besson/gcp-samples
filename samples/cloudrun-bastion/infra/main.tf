locals {
  bastion_image_url = "${var.region}-docker.pkg.dev/${var.project_id}/${data.terraform_remote_state.base.outputs.bastion_repo_name}/bastion:latest"
}

# Resolves the numeric project number from project_id, needed to address the
# project's IAP OAuth brand (see iap.tf) without a redundant input variable.
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

