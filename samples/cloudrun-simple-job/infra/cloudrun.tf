# --- Cloud Run Job ---
# A Cloud Run Job runs a container to completion (batch/task).
# It is triggered manually or via Cloud Scheduler, not via HTTP.
resource "google_cloud_run_v2_job" "hello_job" {
  name     = "hello-world-job"
  location = var.region
  project  = var.project_id

  template {
    template {
      service_account = google_service_account.cloudrun_sa.email

      # Direct VPC Egress: containers run within the private subnet.
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

      # Retry once on failure before marking the task as failed.
      max_retries = 1
    }
  }

  depends_on = [google_artifact_registry_repository.repo]
}
