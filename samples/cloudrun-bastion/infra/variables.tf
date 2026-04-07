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

variable "domain" {
  description = "FQDN for the HTTPS Load Balancer (e.g., bastion.example.com). A DNS A record must point to the static IP output."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9\\-]{0,61}[a-z0-9])?(\\.[a-z0-9]([a-z0-9\\-]{0,61}[a-z0-9])?)+$", var.domain))
    error_message = "The domain must be a valid FQDN (e.g., bastion.example.com)."
  }
}

variable "network" {
  description = "Name of the existing VPC network to use for Direct VPC Egress."
  type        = string
  default     = "default"
}

variable "subnet" {
  description = "Name of the existing VPC subnet to use for Direct VPC Egress."
  type        = string
  default     = "default"
}

variable "iap_user_email" {
  description = "Email of the user or group granted IAP-secured Web App User access (e.g., user@example.com)."
  type        = string
  validation {
    condition     = can(regex("^[^@]+@[^@]+\\.[^@]+$", var.iap_user_email))
    error_message = "iap_user_email must be a valid email address."
  }
}

variable "support_email" {
  description = "Support email shown on the IAP OAuth consent screen. Must belong to the GCP project."
  type        = string
  validation {
    condition     = can(regex("^[^@]+@[^@]+\\.[^@]+$", var.support_email))
    error_message = "support_email must be a valid email address."
  }
}
