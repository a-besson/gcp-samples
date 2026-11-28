module "artifact_registry_job" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.9"

  project_id    = var.project_id
  location      = var.region
  repository_id = "cloudrun-simple-job${var.name_suffix}"
  format        = "DOCKER"
  description   = "Docker repository for cloudrun-simple-job"

  depends_on = [google_project_service.artifact_registry]
}

module "artifact_registry_service" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.9"

  project_id    = var.project_id
  location      = var.region
  repository_id = "cloudrun-simple-service${var.name_suffix}"
  format        = "DOCKER"
  description   = "Docker repository for cloudrun-simple-service"

  depends_on = [google_project_service.artifact_registry]
}

module "artifact_registry_bastion" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.9"

  project_id    = var.project_id
  location      = var.region
  repository_id = "cloudrun-bastion${var.name_suffix}"
  format        = "DOCKER"
  description   = "Docker repository for cloudrun-bastion"

  depends_on = [google_project_service.artifact_registry]
}
