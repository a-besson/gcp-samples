# Enable APIs
module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.5"

  project_id                  = var.project_id
  disable_services_on_destroy = false
  activate_apis = [
    "run.googleapis.com",
    "vpcaccess.googleapis.com",
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com"
  ]
}

# --- Artifact Registry ---
resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.region
  repository_id = "cloudrun-simple"
  description   = "Artifact registry for Cloud Run demo"
  format        = "DOCKER"

  depends_on = [module.project_services]
}
