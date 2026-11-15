variables {
  project_id = "test-project"
  region     = "europe-west1"
  image_job  = "europe-west1-docker.pkg.dev/test-project/cloudrun-simple-job-sample/job:latest"
}

run "validate_cloud_run_job" {
  command = plan

  assert {
    condition     = length(google_cloud_run_v2_job.hello_job.name) > 0
    error_message = "Job name should be defined."
  }

  assert {
    condition     = google_cloud_run_v2_job.hello_job.template[0].template[0].vpc_access[0].egress == "ALL_TRAFFIC"
    error_message = "All traffic should be routed through VPC."
  }
}

run "validate_service_account" {
  command = plan

  assert {
    condition     = google_service_account.cloudrun_sa.account_id == "cloudrun-job-runner${var.name_suffix}"
    error_message = "Service account ID should be cloudrun-job-runner<name_suffix>."
  }
}
