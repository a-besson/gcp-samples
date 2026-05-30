# IaC Service Account — used for deploying all project resources
resource "google_service_account" "iac" {
  account_id   = "sa-iac${var.name_suffix}"
  display_name = "IaC Deployment Service Account"
  project      = var.project_id
}

# Grant broad Editor permissions for resource provisioning
resource "google_project_iam_member" "iac_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.iac.email}"
}

# Grant IAM Admin permissions to manage other service accounts and bindings
resource "google_project_iam_member" "iac_iam_admin" {
  project = var.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${google_service_account.iac.email}"
}

# Grant Storage Admin for managing Terraform state and other buckets
resource "google_project_iam_member" "iac_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.iac.email}"
}

# Grant Secret Manager Admin to manage secrets
resource "google_project_iam_member" "iac_secret_admin" {
  project = var.project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${google_service_account.iac.email}"
}
