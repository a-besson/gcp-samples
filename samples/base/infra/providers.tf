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
  }

  backend "gcs" {
    # Configuration dynamically provided by Task during initialization
  }
}

provider "google" {
  project = var.project_id
  region  = var.region

  default_labels = {
    project    = "base"
    managed-by = "terraform"
    env        = "dev"
  }
}

provider "google-beta" {
  project = var.project_id
  region  = var.region

  default_labels = {
    project    = "base"
    managed-by = "terraform"
    env        = "dev"
  }
}
