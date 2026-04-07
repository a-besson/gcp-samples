variables {
  project_id    = "test-project"
  region        = "europe-west1"
  image_service = "europe-west1-docker.pkg.dev/test-project/cloudrun-simple-service/app:latest"
  network       = "default"
  subnet        = "private-subnet"
}

run "validate_cloud_run_service" {
  command = plan

  assert {
    condition     = google_cloud_run_v2_service.hello_service.ingress == "INGRESS_TRAFFIC_INTERNAL_ONLY"
    error_message = "Ingress should be internal only."
  }

  assert {
    condition     = google_cloud_run_v2_service.hello_service.template[0].vpc_access[0].egress == "ALL_TRAFFIC"
    error_message = "All traffic should be routed through VPC."
  }
}

run "validate_service_account" {
  command = plan

  assert {
    condition     = google_service_account.cloudrun_sa.account_id == "cloudrun-service-runner"
    error_message = "Service account ID should be cloudrun-service-runner."
  }
}
