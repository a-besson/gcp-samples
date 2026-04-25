variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string

  validation {
    condition     = length(var.project_id) > 0
    error_message = "The project_id must not be empty."
  }
}

variable "region" {
  description = "The GCP region to deploy GKE resources in"
  type        = string
  default     = "europe-west9"

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]$", var.region))
    error_message = "The region must be a valid GCP region (e.g. europe-west9)."
  }
}

variable "name_suffix" {
  description = "Suffix for resource naming (used for test isolation)"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of the GKE Autopilot cluster"
  type        = string
  default     = "gke-autopilot"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,38}[a-z0-9]$", var.cluster_name))
    error_message = "Cluster name must be lowercase, start with a letter, and contain only letters, numbers, and hyphens."
  }
}
variable "master_authorized_networks" {
  description = "External networks authorized to access the GKE master endpoint"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}
