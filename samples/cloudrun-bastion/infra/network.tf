# --- Network ---
# VPC and subnets are pre-provisioned in the 'base' module.
# We reference them via remote state to ensure consistency.
data "terraform_remote_state" "base" {
  backend = "gcs"
  config = {
    bucket = "${var.project_id}-tfstate"
    prefix = "base"
  }
}


# --- Private Services Access (For Cloud SQL) ---
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "cloudrun-bastion-db-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.terraform_remote_state.base.outputs.network_self_link
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = data.terraform_remote_state.base.outputs.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]

  depends_on = [module.project_services]
}
