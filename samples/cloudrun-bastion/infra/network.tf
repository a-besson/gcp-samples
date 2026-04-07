# --- Existing VPC Resources ---
data "google_compute_network" "vpc" {
  name    = var.network
  project = var.project_id
}

data "google_compute_subnetwork" "subnet" {
  name    = var.subnet
  region  = var.region
  project = var.project_id
}

# --- Serverless NEG ---
# Bridges the HTTPS Load Balancer to the Cloud Run service.
resource "google_compute_region_network_endpoint_group" "bastion_neg" {
  name                  = "bastion-serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  project               = var.project_id

  cloud_run {
    service = google_cloud_run_v2_service.bastion.name
  }
}

# --- Private Services Access (For Cloud SQL) ---
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "cloudrun-bastion-db-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.vpc.id
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = data.google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]

  depends_on = [module.project_services]
}
