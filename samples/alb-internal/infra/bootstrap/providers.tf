terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
  # GCS backend, configured at `terraform init` time via Taskfile -backend-config
  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region

  default_labels = {
    project    = "gcp-samples_alb-internal"
    managed-by = "terraform"
    env        = "dev"
  }
}

provider "google-beta" {
  project = var.project_id
  region  = var.region

  default_labels = {
    project    = "gcp-samples_alb-internal"
    managed-by = "terraform"
    env        = "dev"
  }
}
