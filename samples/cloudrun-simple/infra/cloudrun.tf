# --- Cloud Run Service ---
resource "google_cloud_run_v2_service" "hello_service" {
  name     = "hello-world-app"
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
      image = var.image_app
      ports {
        container_port = 8080
      }
      env {
        name  = "ENV"
        value = "production"
      }
    }

    scaling {
      max_instance_count = 10
    }
  }

  depends_on = [google_artifact_registry_repository.repo]
}

# --- Cloud Run Job ---
resource "google_cloud_run_v2_job" "hello_job" {
  name     = "hello-world-job"
  location = var.region
  project  = var.project_id

  template {
    template {
      service_account = google_service_account.cloudrun_sa.email

      vpc_access {
        network_interfaces {
          network    = data.google_compute_network.vpc.name
          subnetwork = data.google_compute_subnetwork.subnet.name
        }
        egress = "ALL_TRAFFIC"
      }

      containers {
        image = var.image_job
      }
    }
  }

  depends_on = [google_artifact_registry_repository.repo]
}
