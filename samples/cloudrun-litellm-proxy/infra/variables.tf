variable "project_id" {
  description = "The Google Cloud Project ID hosting the LiteLLM proxy."
  type        = string
}

variable "region" {
  description = "The GCP region used for Cloud Run, Artifact Registry, Secret Manager and Cloud SQL."
  type        = string
  default     = "europe-west9"
}

variable "image_service" {
  description = "Fully-qualified Docker image URI for the LiteLLM proxy container."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+-docker\\.pkg\\.dev/.+/.+:.+$", var.image_service))
    error_message = "image_service must be an Artifact Registry image (REGION-docker.pkg.dev/PROJECT/REPO/NAME:TAG)."
  }
}

variable "service_name" {
  description = "Cloud Run service name."
  type        = string
  default     = "litellm-proxy"
}

variable "min_instances" {
  description = "Minimum Cloud Run instances. 1 = warm pool, 0 = scale-to-zero (cold starts)."
  type        = number
  default     = 1

  validation {
    condition     = var.min_instances >= 0 && var.min_instances <= 5
    error_message = "min_instances must be between 0 and 5 to keep the sample cost-bounded."
  }
}

variable "max_instances" {
  description = "Maximum number of Cloud Run instances."
  type        = number
  default     = 5
}

variable "cpu" {
  description = "vCPU per Cloud Run instance."
  type        = string
  default     = "1"
}

variable "memory" {
  description = "Memory per Cloud Run instance."
  type        = string
  default     = "2Gi"
}

variable "vertex_location" {
  description = "Vertex AI location used by LiteLLM (VERTEXAI_LOCATION env var)."
  type        = string
  default     = "europe-west9"
}

variable "cloudsql_tier" {
  description = "Cloud SQL machine tier for the Postgres instance."
  type        = string
  default     = "db-f1-micro"

  validation {
    condition     = can(regex("^db-", var.cloudsql_tier))
    error_message = "cloudsql_tier must be a valid Cloud SQL tier (e.g. db-f1-micro, db-g1-small)."
  }
}

variable "dns_name" {
  description = "Custom domain for the Cloud Run service (e.g. llm.example.com). Leave empty to skip DNS and domain-mapping resources."
  type        = string
  default     = ""
}

variable "bigquery_dataset" {
  description = "BigQuery dataset ID for LiteLLM observability logs (tokens, cost, latency)."
  type        = string
  default     = "litellm_observability"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]+$", var.bigquery_dataset))
    error_message = "bigquery_dataset must contain only letters, numbers, and underscores."
  }
}

variable "name_suffix" {
  description = "Suffix appended to resource names (used for test isolation)."
  type        = string
  default     = "-sample"
}

variable "billing_account" {
  description = "Billing account ID (e.g. 0X0X0X-0X0X0X-0X0X0X) used to create a cost budget alert. Leave empty to skip the budget. The IaC service account needs roles/billing.costsManager on this account."
  type        = string
  default     = ""
}

variable "monthly_budget_amount" {
  description = "Monthly cost budget threshold (in the billing account currency) for the budget alert. Alerts fire at 50%, 90%, and 100%."
  type        = number
  default     = 50

  validation {
    condition     = var.monthly_budget_amount > 0
    error_message = "monthly_budget_amount must be greater than 0."
  }
}
