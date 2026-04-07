variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "The region to deploy resources in"
  type        = string
  default     = "europe-west1"
  validation {
    condition     = can(regex("^[a-z]+-[a-z0-9]+$", var.region))
    error_message = "The region must be a valid GCP region (e.g., europe-west1)."
  }
}

variable "image_app" {
  description = "Docker image for the hello world service (built with APP_MODE=service)"
  type        = string
}

variable "image_job" {
  description = "Docker image for the cloud run job (built with APP_MODE=job)"
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
  default     = "private-subnet"
}
