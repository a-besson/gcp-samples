# --- Network ---
# VPC and subnets are pre-provisioned. We reference existing resources.
data "google_compute_network" "vpc" {
  name    = var.network
  project = var.project_id
}

data "google_compute_subnetwork" "subnet" {
  name    = var.subnet
  region  = var.region
  project = var.project_id
}
