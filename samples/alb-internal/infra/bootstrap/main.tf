# Resolves the numeric project number from project_id, needed to address
# Google-managed service agents (see kms.tf) without a redundant variable.
data "google_project" "this" {
  project_id = var.project_id
}

# Enable required GCP APIs for both the bootstrap stack (this one) and the
# main stack (infra/), which reads this stack's outputs via remote_state.
module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.0"

  project_id                  = var.project_id
  disable_services_on_destroy = false
  activate_apis = [
    "compute.googleapis.com",
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "iap.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "oslogin.googleapis.com",
  ]
}

# On a project where an API has never been used before, its activation can
# take several minutes to propagate across GCP's backends even after
# module.project_services reports success - without this wait, the very next
# resources (KMS key ring, service identities) intermittently fail with
# "API has not been used in project ... or it is disabled".
resource "time_sleep" "wait_for_apis" {
  depends_on      = [module.project_services]
  create_duration = "60s"
}

# Force-create the Google-managed service agents up front. Without this,
# the CMEK IAM bindings in kms.tf fail with "service account does not exist"
# on a fresh project, since agents are normally created lazily on first use.
resource "google_project_service_identity" "agents" {
  provider = google-beta
  for_each = toset([
    "sqladmin.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
  ])
  project    = var.project_id
  service    = each.value
  depends_on = [time_sleep.wait_for_apis]
}
