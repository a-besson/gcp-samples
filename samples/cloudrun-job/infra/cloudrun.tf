# --- Cloud Run Job ---
# A Cloud Run Job runs a container to completion (batch/task).
# It is triggered manually or via Cloud Scheduler, not via HTTP.
resource "google_cloud_run_v2_job" "hello_job" {
  name                = "hello-world-job${var.name_suffix}"
  location            = var.region
  project             = var.project_id
  deletion_protection = false

  template {
    template {
      service_account = google_service_account.cloudrun_sa.email

      # Direct VPC Egress: containers run within the private subnet.
      vpc_access {
        network_interfaces {
          network    = data.terraform_remote_state.base.outputs.network_name
          subnetwork = data.terraform_remote_state.base.outputs.subnet_priv_a.name
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

  depends_on = [module.project_services]
}
