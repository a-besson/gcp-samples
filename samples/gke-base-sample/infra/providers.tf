terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 7.0"
    }
  }
  backend "gcs" {}
}

provider "google" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = "sa-iac${var.name_suffix}@${var.project_id}.iam.gserviceaccount.com"

  default_labels = {
    project    = "gcp-samples_gke-base-sample"
    managed-by = "terraform"
    env        = "dev"
  }
}

provider "google-beta" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = "sa-iac${var.name_suffix}@${var.project_id}.iam.gserviceaccount.com"

  default_labels = {
    project    = "gcp-samples_gke-base-sample"
    managed-by = "terraform"
    env        = "dev"
  }
}
