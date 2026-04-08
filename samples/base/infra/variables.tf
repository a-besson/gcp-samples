variable "project_id" {
  description = "The GCP Project ID where the VPC will be created."
  type        = string
}



variable "region" {
  description = "The region where subnets will be deployed."
  type        = string
  default     = "europe-west9"
}

variable "subnet_public_name" {
  description = "Name of the public subnet."
  type        = string
  default     = "subnet-public"
}

variable "subnet_public_ip" {
  description = "IP range for the public subnet."
  type        = string
  default     = "10.0.0.0/22"
}

variable "subnet_priv_a_name" {
  description = "Name of the first private subnet."
  type        = string
  default     = "subnet-priv-a"
}

variable "subnet_priv_a_ip" {
  description = "IP range for the first private subnet."
  type        = string
  default     = "10.0.4.0/22"
}

variable "subnet_priv_a_secondary_ip" {
  description = "Secondary IP range for the first private subnet."
  type        = string
  default     = "100.64.0.0/22"
}

variable "subnet_priv_b_name" {
  description = "Name of the second private subnet."
  type        = string
  default     = "subnet-priv-b"
}

variable "subnet_priv_b_ip" {
  description = "IP range for the second private subnet."
  type        = string
  default     = "10.0.20.0/22"
}

variable "subnet_priv_b_secondary_ip" {
  description = "Secondary IP range for the second private subnet."
  type        = string
  default     = "100.64.4.0/22"
}

variable "name_suffix" {
  description = "Suffix for resource names (used in tests to avoid naming conflicts)."
  type        = string
  default     = ""
}
