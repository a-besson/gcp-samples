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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
  # GCS backend, configured at `terraform init` time via Taskfile -backend-config
  backend "gcs" {}
}

# Standalone sample: no `impersonate_service_account`. The VPC, KMS keys and
# every resource below belong to this sample alone, not to samples/base — the
# operator's own ADC credentials are used directly.
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
