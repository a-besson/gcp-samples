terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
  # Uncomment and configure for production use
  # backend "gcs" {
  #   bucket = "YOUR-TFSTATE-BUCKET"
  #   prefix = "cloudrun-bastion"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
