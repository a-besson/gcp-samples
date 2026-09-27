variable "project_id" {
  description = "The Google Cloud Project ID."
  type        = string
  validation {
    condition     = length(var.project_id) > 0
    error_message = "project_id must not be empty."
  }
}

variable "region" {
  description = "The GCP region for every resource in this sample. Overrides the root .env REGION (europe-west9): this sample is pinned to Belgium."
  type        = string
  default     = "europe-west1"
  validation {
    condition     = can(regex("^[a-z]+-[a-z0-9]+$", var.region))
    error_message = "The region must be a valid GCP region (e.g., europe-west1)."
  }
}

variable "name_suffix" {
  description = "Suffix for resource names (e.g. -dev or -test)."
  type        = string
  default     = "-sample"
  validation {
    # Concatenated directly onto every resource name in this stack (e.g.
    # "alb-internal-api${var.name_suffix}"): a leading hyphen, lowercase
    # alphanumeric, no trailing hyphen - anything else fails GCP resource
    # naming rules at apply time, across every resource at once.
    condition     = can(regex("^-[a-z0-9]+(-[a-z0-9]+)*$", var.name_suffix))
    error_message = "name_suffix must start with a hyphen and contain only lowercase letters, digits and hyphens (e.g. -dev, -test), with no trailing hyphen."
  }
}

variable "iap_user_email" {
  description = "Email of the user or group granted IAP access to the API and SSH tunnel access to the client VM (e.g., user@example.com)."
  type        = string
  validation {
    condition     = can(regex("^[^@]+@[^@]+\\.[^@]+$", var.iap_user_email))
    error_message = "iap_user_email must be a valid email address."
  }
}

variable "db_tier" {
  description = "Cloud SQL machine tier. db-f1-micro is the lowest-cost shared-core tier, suitable for a demo workload."
  type        = string
  default     = "db-f1-micro"
  validation {
    condition     = can(regex("^db-", var.db_tier))
    error_message = "db_tier must be a valid Cloud SQL tier (e.g. db-f1-micro, db-custom-2-8192)."
  }
}

variable "vpc_cidr_isolated" {
  description = "CIDR range for subnet-isolated (client VM + ILB forwarding rule VIP)."
  type        = string
  default     = "10.20.0.0/24"
  validation {
    condition     = can(cidrhost(var.vpc_cidr_isolated, 0))
    error_message = "vpc_cidr_isolated must be a valid CIDR range (e.g. 10.20.0.0/24)."
  }
}

variable "vpc_cidr_application" {
  description = "CIDR range for subnet-isolated-application (Cloud Run Direct VPC Egress NIC + Cloud SQL PSC endpoint)."
  type        = string
  default     = "10.20.1.0/24"
  validation {
    condition     = can(cidrhost(var.vpc_cidr_application, 0))
    error_message = "vpc_cidr_application must be a valid CIDR range (e.g. 10.20.1.0/24)."
  }
}

variable "vpc_cidr_proxy_only" {
  description = "CIDR range for the mandatory REGIONAL_MANAGED_PROXY subnet used by the regional internal Application Load Balancer."
  type        = string
  default     = "10.20.2.0/24"
  validation {
    condition     = can(cidrhost(var.vpc_cidr_proxy_only, 0))
    error_message = "vpc_cidr_proxy_only must be a valid CIDR range (e.g. 10.20.2.0/24)."
  }
}

variable "alert_notification_channels" {
  description = "Monitoring notification channel IDs notified when Cloud Armor blocks an abnormal volume of traffic (format: projects/<project>/notificationChannels/<id>). Empty by default: the alert policy is still created and visible in the console, but sends no notification."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for c in var.alert_notification_channels : can(regex("^projects/[^/]+/notificationChannels/[0-9]+$", c))])
    error_message = "Each notification channel must be a full resource name: projects/<project>/notificationChannels/<id>."
  }
}
