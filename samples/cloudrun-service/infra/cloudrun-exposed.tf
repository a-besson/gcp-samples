# --- Cloud Run Service ---
resource "google_cloud_run_v2_service" "exposed_service" {
  name                = "exposed-service${var.name_suffix}"
  location            = var.region
  project             = var.project_id
  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false
  template {
    service_account = google_service_account.exposed_service_sa.email

    # Direct VPC Egress: access private base VPC resources.
    vpc_access {
      network_interfaces {
        network    = data.terraform_remote_state.base.outputs.network_name
        subnetwork = data.terraform_remote_state.base.outputs.subnet_public.name
      }
      egress = "ALL_TRAFFIC"
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
resource "google_service_account" "exposed_service_sa" {
  account_id   = "exp-srv-runner${var.name_suffix}"
  display_name = "Runner for Cloud Run REST Service"
  project      = var.project_id
}
