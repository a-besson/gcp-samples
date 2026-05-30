variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources in"
  type        = string
  default     = "europe-west1"
}

variable "image_service" {
  description = "Docker image for the Cloud Run service"
  type        = string
}

variable "name_suffix" {
  description = "Suffix for resource naming (used for test isolation)"
  type        = string
  default     = "-sample"
}
