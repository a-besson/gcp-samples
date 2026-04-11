module "artifact_registry_job" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.8"

  project_id    = var.project_id
  location      = var.region
  repository_id = "cloudrun-simple-job${var.name_suffix}"
  format        = "DOCKER"
  description   = "Docker repository for cloudrun-simple-job"
}

module "artifact_registry_service" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.8"

  project_id    = var.project_id
  location      = var.region
  repository_id = "cloudrun-simple-service${var.name_suffix}"
  format        = "DOCKER"
  description   = "Docker repository for cloudrun-simple-service"
}

module "artifact_registry_bastion" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.8"

  project_id    = var.project_id
  location      = var.region
  repository_id = "cloudrun-bastion${var.name_suffix}"
  format        = "DOCKER"
  description   = "Docker repository for cloudrun-bastion"
}

# Container Scanning API ensures vulnerability scanning is active
resource "google_project_service" "container_scanning" {
  project            = var.project_id
  service            = "containerscanning.googleapis.com"
  disable_on_destroy = false
}
