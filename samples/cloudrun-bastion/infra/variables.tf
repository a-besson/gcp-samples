variable "project_id" {
  description = "The Google Cloud Project ID."
  type        = string
}

variable "region" {
  description = "The GCP region to deploy the Cloud Run service."
  type        = string
  default     = "europe-west1"
  validation {
    condition     = can(regex("^[a-z]+-[a-z0-9]+$", var.region))
    error_message = "The region must be a valid GCP region (e.g., europe-west1)."
  }
}


variable "iap_user_email" {
  description = "Email of the user or group granted IAP-secured Web App User access (e.g., user@example.com)."
  type        = string
  validation {
    condition     = can(regex("^[^@]+@[^@]+\\.[^@]+$", var.iap_user_email))
    error_message = "iap_user_email must be a valid email address."
  }
}

variable "name_suffix" {
  description = "Suffix for the resource names (e.g. -dev or -test)."
  type        = string
  default     = "-sample"
}
