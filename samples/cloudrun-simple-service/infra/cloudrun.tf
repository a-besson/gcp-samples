# --- Cloud Run Service ---
# Ingress restricted to internal-only: accessible via gcloud run services proxy or
# through an internal Load Balancer — no direct internet access.
resource "google_cloud_run_v2_service" "hello_service" {
  name     = "hello-world-service"
  location = var.region
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    service_account = google_service_account.cloudrun_sa.email

    # Direct VPC Egress: containers attach directly to the private subnet.
    vpc_access {
      network_interfaces {
        network    = data.google_compute_network.vpc.name
        subnetwork = data.google_compute_subnetwork.subnet.name
      }
      egress = "ALL_TRAFFIC"
    }

    containers {
      image = var.image_service
      ports {
        container_port = 8080
      }
      env {
        name  = "ENV"
        value = "production"
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }
  }

  depends_on = [google_artifact_registry_repository.repo]
}
