# --- Cloud Run Bastion Service ---
# Ingress is set to INTERNAL_LOAD_BALANCER so only the HTTPS LB (protected by IAP)
# can reach this service. Direct internet access is blocked.
resource "google_cloud_run_v2_service" "bastion" {
  name                = "cloudrun-bastion${var.name_suffix}"
  location            = var.region
  project             = var.project_id
  ingress             = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  deletion_protection = false

  template {
    service_account = google_service_account.bastion_sa.email

    # Direct VPC Egress: container traffic routes through the private subnet,
    # giving the bastion visibility into private VPC resources.
    vpc_access {
      network_interfaces {
        network    = data.terraform_remote_state.base.outputs.network_name
        subnetwork = data.terraform_remote_state.base.outputs.subnet_priv_a.id
      }
      egress = "ALL_TRAFFIC"
    }

    containers {
      image = local.bastion_image_url
      ports {
        container_port = 8080
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }
  }

}
