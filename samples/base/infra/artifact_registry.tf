# Required APIs for the base infrastructure
resource "google_project_service" "artifact_registry" {
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  project            = var.project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

# Container Scanning API ensures vulnerability scanning is active
resource "google_project_service" "container_scanning" {
  project            = var.project_id
  service            = "containerscanning.googleapis.com"
  disable_on_destroy = false
}

module "artifact_registry_job" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.8"

  project_id    = var.project_id
  location      = var.region
  repository_id = "cloudrun-simple-job${var.name_suffix}"
  format        = "DOCKER"
  description   = "Docker repository for cloudrun-simple-job"

  depends_on = [google_project_service.artifact_registry]
}

module "artifact_registry_service" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.8"

  project_id    = var.project_id
  location      = var.region
  repository_id = "cloudrun-simple-service${var.name_suffix}"
  format        = "DOCKER"
  description   = "Docker repository for cloudrun-simple-service"

  depends_on = [google_project_service.artifact_registry]
}

module "artifact_registry_bastion" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.8"

  project_id    = var.project_id
  location      = var.region
  repository_id = "cloudrun-bastion${var.name_suffix}"
  format        = "DOCKER"
  description   = "Docker repository for cloudrun-bastion"

  depends_on = [google_project_service.artifact_registry]
}
