terraform {
  required_version = "~> 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Uncomment and set YOUR-TFSTATE-BUCKET once the GCS bucket is provisioned.
  backend "gcs" {}
}

provider "google" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = "sa-iac${var.name_suffix}@${var.project_id}.iam.gserviceaccount.com"

  default_labels = {
    project    = "gcp-samples_cloudrun-job"
    managed-by = "terraform"
    env        = "dev"
  }
}
