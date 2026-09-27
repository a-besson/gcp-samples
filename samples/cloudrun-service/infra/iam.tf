# --- IAM Auth ---
# No allUsers binding: authentication is mandatory.
# Access is granted via IAM roles/run.invoker on the service resource.

resource "google_cloud_run_v2_service_iam_member" "invoker" {
  location = var.region
  project  = var.project_id
  name     = google_cloud_run_v2_service.exposed_service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.exposed_service_sa.email}"
}


# Create a Test SA for authenticated calls
resource "google_service_account" "test_sa" {
  account_id   = "exp-srv-tester${var.name_suffix}"
  display_name = "Service Account for E2E Tests"
  project      = var.project_id
}

resource "google_cloud_run_v2_service_iam_member" "test_sa_invoker" {
  location = var.region
  project  = var.project_id
  name     = google_cloud_run_v2_service.exposed_service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.test_sa.email}"
}

# --- E2E test bootstrap ---
# `task e2e` mints an identity token by impersonating test_sa from the
# operator's own machine (not through sa-iac: this task deliberately clears
# the Taskfile's ambient impersonation, see Taskfile.yml). Without this
# binding, that impersonation fails with "iam.serviceAccounts.getAccessToken
# denied" - test_sa existing and holding run.invoker is not enough on its
# own, same bootstrap gap as sa-iac in samples/base.
data "google_client_openid_userinfo" "operator" {}

resource "google_service_account_iam_member" "test_sa_token_creator" {
  service_account_id = google_service_account.test_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "user:${data.google_client_openid_userinfo.operator.email}"
}
