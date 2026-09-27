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
    litellm = {
      source  = "ncecere/litellm"
      version = "~> 2.0"
    }
  }
  backend "gcs" {}
}

provider "litellm" {
  api_base = google_cloud_run_v2_service.litellm.uri
  api_key  = "Bearer ${data.google_secret_manager_secret_version.master_key.secret_data}"
}

provider "google" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = "sa-iac${var.name_suffix}@${var.project_id}.iam.gserviceaccount.com"

  default_labels = {
    project    = "gcp-samples_cloudrun-litellm-proxy"
    managed-by = "terraform"
    env        = "dev"
  }
}

provider "google-beta" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = "sa-iac${var.name_suffix}@${var.project_id}.iam.gserviceaccount.com"

  default_labels = {
    project    = "gcp-samples_cloudrun-litellm-proxy"
    managed-by = "terraform"
    env        = "dev"
  }
}
