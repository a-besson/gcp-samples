terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
  # Remote backend configuration is usually required for industrial projects.
  # For this example, we'll comment it out or use an example-style.
  # backend "gcs" {
  #   bucket = "YOUR-TFSTATE-BUCKET"
  #   prefix = "cloudrun-simple"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
