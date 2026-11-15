variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
  validation {
    condition     = length(var.project_id) > 0
    error_message = "project_id must not be empty."
  }
}

variable "region" {
  description = "The GCP region to deploy resources in"
  type        = string
  default     = "europe-west1"
  validation {
    condition     = can(regex("^[a-z]+-[a-z0-9]+$", var.region))
    error_message = "The region must be a valid GCP region (e.g., europe-west1)."
  }
}

variable "image_job" {
  description = "Docker image for the Cloud Run Job"
  type        = string
  validation {
    condition     = length(var.image_job) > 0
    error_message = "image_job must not be empty."
  }
}

variable "name_suffix" {
  description = "Suffix for the resource names (e.g. -dev or -test)."
  type        = string
  default     = "-sample"
  validation {
    # Appended to resource names ("cloudrun-job-runner" + suffix is a 30-character service account id): a leading hyphen, lowercase
    # alphanumerics, no trailing hyphen (same rule as alb-internal).
    condition     = can(regex("^-[a-z0-9]+(-[a-z0-9]+)*$", var.name_suffix)) && length(var.name_suffix) <= 11
    error_message = "name_suffix must start with a hyphen, contain only lowercase letters, digits and hyphens, end with a letter or digit, and be at most 11 characters."
  }
}
