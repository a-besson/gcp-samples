# --- Cloud Run Service ---
resource "google_cloud_run_v2_service" "internal_service" {
  name                = "internal-service${var.name_suffix}"
  location            = var.region
  project             = var.project_id
  ingress             = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  deletion_protection = false
  template {
    service_account = google_service_account.internal_service_sa.email

    # Direct VPC Egress: access private base VPC resources.
    vpc_access {
      network_interfaces {
        network    = data.terraform_remote_state.base.outputs.network_name
        subnetwork = data.terraform_remote_state.base.outputs.subnet_priv_a.name
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = var.image_service
      ports {
        # Configured to listen on 443 as per user request.
        container_port = 443
      }
    }
  }
}

# --- Service Account ---
resource "google_service_account" "internal_service_sa" {
  account_id   = "int-srv-runner${var.name_suffix}"
  display_name = "Runner for Cloud Run Internal Service"
  project      = var.project_id
}
