terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    # Configuration dynamically provided by Task during initialization
  }
}

provider "google" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = "sa-iac${var.name_suffix}@${var.project_id}.iam.gserviceaccount.com"

  default_labels = {
    project    = "gcp-samples_gce-g2-gpu-instance"
    managed-by = "terraform"
    env        = "dev"
  }
}
