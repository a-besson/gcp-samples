variable "project_id" {
  description = "The Google Cloud Project ID."
  type        = string
  validation {
    condition     = length(var.project_id) > 0
    error_message = "project_id must not be empty."
  }
}

variable "region" {
  description = "The GCP region for the KMS key ring and the Artifact Registry repository. Must match the region used by infra/ (Cloud SQL, Cloud Run)."
  type        = string
  default     = "europe-west1"
  validation {
    condition     = can(regex("^[a-z]+-[a-z0-9]+$", var.region))
    error_message = "The region must be a valid GCP region (e.g., europe-west1)."
  }
}

variable "name_suffix" {
  description = "Suffix for resource names (e.g. -dev or -test). Changing it creates a fresh KMS key ring, since key rings can never be deleted from GCP."
  type        = string
  default     = "-sample"
  validation {
    # Same constraint as infra/variables.tf: concatenated directly onto every
    # resource name in this stack too (key ring, crypto keys, AR repo).
    condition     = can(regex("^-[a-z0-9]+(-[a-z0-9]+)*$", var.name_suffix))
    error_message = "name_suffix must start with a hyphen and contain only lowercase letters, digits and hyphens (e.g. -dev, -test), with no trailing hyphen."
  }
}
