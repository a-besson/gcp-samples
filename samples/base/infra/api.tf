# Required APIs for the base infrastructure

# Needed by every google_project_iam_member / google_service_account_iam_member
# below (getIamPolicy/setIamPolicy on the project itself) - without it, the
# first apply on a fresh project fails with "Cloud Resource Manager API has
# not been used in project ... before or it is disabled", on whichever IAM
# grant Terraform happens to reach first.
resource "google_project_service" "cloudresourcemanager" {
  project            = var.project_id
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

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
