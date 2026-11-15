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
  default     = "-sample"
  validation {
    # Appended to resource names (the impersonated "sa-iac" + suffix is a 30-character service account id): a leading hyphen, lowercase
    # alphanumerics, no trailing hyphen (same rule as alb-internal).
    condition     = can(regex("^-[a-z0-9]+(-[a-z0-9]+)*$", var.name_suffix)) && length(var.name_suffix) <= 24
    error_message = "name_suffix must start with a hyphen, contain only lowercase letters, digits and hyphens, end with a letter or digit, and be at most 24 characters."
  }
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
  validation {
    condition     = alltrue([for n in var.master_authorized_networks : can(cidrhost(n.cidr_block, 0))])
    error_message = "Each master_authorized_networks cidr_block must be a valid CIDR range."
  }
}
