terraform {
  required_version = ">= 1.9.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.50"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5"
    }
  }
}
