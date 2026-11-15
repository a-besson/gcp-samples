variable "project_id" {
  description = "The GCP Project ID where the VPC will be created."
  type        = string
  validation {
    condition     = length(var.project_id) > 0
    error_message = "project_id must not be empty."
  }
}



variable "region" {
  description = "The region where subnets will be deployed."
  type        = string
  default     = "europe-west9"
  validation {
    condition     = can(regex("^[a-z]+-[a-z0-9]+$", var.region))
    error_message = "The region must be a valid GCP region (e.g., europe-west1)."
  }
}

variable "subnet_public_name" {
  description = "Name of the public subnet."
  type        = string
  default     = "subnet-public"
  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]*[a-z0-9])?$", var.subnet_public_name))
    error_message = "subnet_public_name must be a valid GCP resource name (lowercase letters, digits and hyphens)."
  }
}

variable "subnet_public_ip" {
  description = "IP range for the public subnet."
  type        = string
  default     = "10.0.0.0/22"
  validation {
    condition     = can(cidrhost(var.subnet_public_ip, 0))
    error_message = "subnet_public_ip must be a valid CIDR range."
  }
}

variable "subnet_priv_a_name" {
  description = "Name of the first private subnet."
  type        = string
  default     = "subnet-priv-a"
  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]*[a-z0-9])?$", var.subnet_priv_a_name))
    error_message = "subnet_priv_a_name must be a valid GCP resource name (lowercase letters, digits and hyphens)."
  }
}

variable "subnet_priv_a_ip" {
  description = "IP range for the first private subnet."
  type        = string
  default     = "10.0.4.0/22"
  validation {
    condition     = can(cidrhost(var.subnet_priv_a_ip, 0))
    error_message = "subnet_priv_a_ip must be a valid CIDR range."
  }
}

variable "subnet_priv_a_secondary_ip" {
  description = "Secondary IP range for the first private subnet."
  type        = string
  default     = "100.64.0.0/22"
  validation {
    condition     = can(cidrhost(var.subnet_priv_a_secondary_ip, 0))
    error_message = "subnet_priv_a_secondary_ip must be a valid CIDR range."
  }
}

variable "subnet_priv_b_name" {
  description = "Name of the second private subnet."
  type        = string
  default     = "subnet-priv-b"
  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]*[a-z0-9])?$", var.subnet_priv_b_name))
    error_message = "subnet_priv_b_name must be a valid GCP resource name (lowercase letters, digits and hyphens)."
  }
}

variable "subnet_priv_b_ip" {
  description = "IP range for the second private subnet."
  type        = string
  default     = "10.0.20.0/22"
  validation {
    condition     = can(cidrhost(var.subnet_priv_b_ip, 0))
    error_message = "subnet_priv_b_ip must be a valid CIDR range."
  }
}

variable "subnet_priv_b_secondary_ip" {
  description = "Secondary IP range for the second private subnet."
  type        = string
  default     = "100.64.4.0/22"
  validation {
    condition     = can(cidrhost(var.subnet_priv_b_secondary_ip, 0))
    error_message = "subnet_priv_b_secondary_ip must be a valid CIDR range."
  }
}

variable "name_suffix" {
  description = "Suffix for resource names (used in tests to avoid naming conflicts)."
  type        = string
  default     = "-sample"
  validation {
    # Appended to resource names ("test-vm-sa" + suffix is a 30-character service account id): a leading hyphen, lowercase
    # alphanumerics, no trailing hyphen (same rule as alb-internal).
    condition     = can(regex("^-[a-z0-9]+(-[a-z0-9]+)*$", var.name_suffix)) && length(var.name_suffix) <= 20
    error_message = "name_suffix must start with a hyphen, contain only lowercase letters, digits and hyphens, end with a letter or digit, and be at most 20 characters."
  }
}
