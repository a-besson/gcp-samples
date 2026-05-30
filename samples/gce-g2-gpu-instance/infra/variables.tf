variable "project_id" {
  description = "GCP Project ID"
  type        = string
  validation {
    condition     = length(var.project_id) > 0
    error_message = "project_id must not be empty."
  }
}

variable "region" {
  description = "GCP Region (Default to Netherlands as L4 is more available there)"
  type        = string
  default     = "europe-west4"
  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]+$", var.region))
    error_message = "region must be a valid GCP region (e.g., europe-west4)."
  }
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "europe-west4-a"
  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]+-[a-z]$", var.zone))
    error_message = "zone must be a valid GCP zone (e.g., europe-west4-a)."
  }
}

variable "machine_type" {
  description = "GCE Machine Type (G2 series for L4 GPU)"
  type        = string
  default     = "g2-standard-8"
  validation {
    condition     = can(regex("^g2-", var.machine_type))
    error_message = "machine_type must be a G2 series instance (e.g., g2-standard-4, g2-standard-8)."
  }
}

variable "gpu_type" {
  description = "GPU Type"
  type        = string
  default     = "nvidia-l4"
  validation {
    condition     = contains(["nvidia-l4", "nvidia-tesla-t4", "nvidia-tesla-v100", "nvidia-a100-80gb"], var.gpu_type)
    error_message = "gpu_type must be a supported NVIDIA GPU type (nvidia-l4, nvidia-tesla-t4, nvidia-tesla-v100, nvidia-a100-80gb)."
  }
}

variable "gpu_count" {
  description = "Number of GPUs"
  type        = number
  default     = 1
  validation {
    condition     = var.gpu_count >= 1 && var.gpu_count <= 8
    error_message = "gpu_count must be between 1 and 8."
  }
}

variable "is_spot" {
  description = "Whether to use Spot instance for cost reduction"
  type        = bool
  default     = false
}

variable "name_suffix" {
  description = "Suffix for the resource names (e.g. -dev or -test)."
  type        = string
  default     = "-sample"
}
