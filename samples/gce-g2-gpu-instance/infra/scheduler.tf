data "google_project" "project" {
  project_id = var.project_id
}

resource "google_compute_resource_policy" "llm_schedule" {
  name    = "llm-start-stop-policy"
  region  = var.region
  project = var.project_id

  instance_schedule_policy {
    vm_start_schedule {
      schedule = "0 7 * * *"
    }
    vm_stop_schedule {
      schedule = "0 21 * * *"
    }
    time_zone = "Europe/Paris"
  }
}

# Grant permission to the Compute Engine Service Agent to start/stop instances
# This account is responsible for executing the schedule.
resource "google_project_iam_member" "compute_agent_scheduler" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin"
  member  = "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com"
}
