# IaC Service Account — used for deploying all project resources
resource "google_service_account" "iac" {
  account_id   = "sa-iac${var.name_suffix}"
  display_name = "IaC Deployment Service Account"
  project      = var.project_id
}

# Grant broad Editor permissions for resource provisioning
resource "google_project_iam_member" "iac_editor" {
  project    = var.project_id
  role       = "roles/editor"
  member     = "serviceAccount:${google_service_account.iac.email}"
  depends_on = [google_project_service.cloudresourcemanager]
}

# Grant IAM Admin permissions to manage other service accounts and bindings
resource "google_project_iam_member" "iac_iam_admin" {
  project    = var.project_id
  role       = "roles/resourcemanager.projectIamAdmin"
  member     = "serviceAccount:${google_service_account.iac.email}"
  depends_on = [google_project_service.cloudresourcemanager]
}

# Grant Storage Admin for managing Terraform state and other buckets
resource "google_project_iam_member" "iac_storage_admin" {
  project    = var.project_id
  role       = "roles/storage.admin"
  member     = "serviceAccount:${google_service_account.iac.email}"
  depends_on = [google_project_service.cloudresourcemanager]
}

# Grant Secret Manager Admin to manage secrets
resource "google_project_iam_member" "iac_secret_admin" {
  project    = var.project_id
  role       = "roles/secretmanager.admin"
  member     = "serviceAccount:${google_service_account.iac.email}"
  depends_on = [google_project_service.cloudresourcemanager]
}

# --- Impersonation bootstrap ---
# Every other sample's Taskfile sets GOOGLE_IMPERSONATE_SERVICE_ACCOUNT /
# CLOUDSDK_AUTH_IMPERSONATE_SERVICE_ACCOUNT to this SA (least-privilege: the
# operator's own broad ADC credentials never touch downstream stacks
# directly). Without this binding, that impersonation always fails with
# "iam.serviceAccounts.getAccessToken denied", since nobody is granted rights
# to mint tokens for sa-iac - this SA existing is not enough on its own.
#
# The identity to grant is the operator authenticating THIS apply itself:
# `base` never impersonates (sa-iac doesn't exist yet on a fresh project),
# so `google_client_openid_userinfo` reliably resolves to that same
# operator, with zero extra input variable.
data "google_client_openid_userinfo" "operator" {}

resource "google_service_account_iam_member" "iac_token_creator" {
  service_account_id = google_service_account.iac.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "user:${data.google_client_openid_userinfo.operator.email}"
}
