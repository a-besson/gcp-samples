locals {
  bastion_image_url = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.name}/bastion:latest"
}

# Enable required GCP APIs
module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 17.0"

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

# Artifact Registry repository for the bastion image
resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.region
  repository_id = "cloudrun-bastion"
  description   = "Docker repository for the Cloud Run bastion SOCKS5 proxy"
  format        = "DOCKER"

  depends_on = [module.project_services]
}

# --- Docker Build and Push ---
# Resolves the chicken-and-egg problem by building and pushing the image
# as soon as the Artifact Registry is created.
resource "null_resource" "docker_build_push" {
  triggers = {
    # Re-run if Dockerfile or sockd.conf changes
    dockerfile = filesha256("${path.module}/../app/Dockerfile")
    conf       = filesha256("${path.module}/../app/sockd.conf")
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      gcloud auth configure-docker ${var.region}-docker.pkg.dev --quiet
      podman build -t ${local.bastion_image_url} ${path.module}/../app
      podman push ${local.bastion_image_url}
    EOT
  }

  depends_on = [google_artifact_registry_repository.repo]
}
