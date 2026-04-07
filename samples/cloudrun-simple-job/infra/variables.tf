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
}

variable "network" {
  description = "VPC network name"
  type        = string
  default     = "default"
}

variable "subnet" {
  description = "VPC subnet name"
  type        = string
  default     = "default"
}
