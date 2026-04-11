# Enable APIs
module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.0"

  project_id                  = var.project_id
  disable_services_on_destroy = false
  activate_apis = [
    "run.googleapis.com",
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com"
  ]
}

# --- Artifact Registry ---
# Uses the official terraform-google-modules module with vulnerability scanning enabled.
module "artifact_registry" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.8"

  project_id    = var.project_id
  location      = var.region
  repository_id = "cloudrun-simple-job"
  description   = "Docker images for Cloud Run Job"
  format        = "DOCKER"

  depends_on = [module.project_services]
}
