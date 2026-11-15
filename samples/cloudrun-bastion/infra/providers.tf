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
  }
  # Uncomment and configure for production use
  backend "gcs" {}
}

provider "google" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = "sa-iac${var.name_suffix}@${var.project_id}.iam.gserviceaccount.com"

  default_labels = {
    project    = "gcp-samples_cloudrun-bastion"
    managed-by = "terraform"
    env        = "dev"
  }
}

# Used by the official modules (see the module resources declaring
# `provider = google-beta`): configured explicitly so those resources get the
# same default_labels and impersonation as the google provider, and a pinned
# major instead of whatever google-beta release is newest.
provider "google-beta" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = "sa-iac${var.name_suffix}@${var.project_id}.iam.gserviceaccount.com"

  default_labels = {
    project    = "gcp-samples_cloudrun-bastion"
    managed-by = "terraform"
    env        = "dev"
  }
}
