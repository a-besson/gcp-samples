# 100% offline unit tests: mock_provider replaces every google/google-beta
# API call, so this file runs in CI with zero GCP credentials
# (`task test` = `terraform init -backend=false` + `terraform test`).

mock_provider "google" {}
mock_provider "google-beta" {}

# Outputs read from the base stack (GCS remote state) in a real plan.
override_data {
  target = data.terraform_remote_state.base
  values = {
    outputs = {
      network_name      = "gcp-sample-base-vpc-test"
      network_self_link = "projects/test-project/global/networks/gcp-sample-base-vpc-test"
      bastion_repo_name = "cloudrun-bastion-test"
      subnet_public     = { id = "projects/test-project/regions/europe-west1/subnetworks/subnet-public-test", name = "subnet-public-test", ip_cidr_range = "10.0.0.0/22" }
      subnet_priv_a     = { id = "projects/test-project/regions/europe-west1/subnetworks/subnet-priv-a-test", name = "subnet-priv-a-test", ip_cidr_range = "10.0.4.0/22" }
    }
  }
}

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

# "cloudrun-job-runner" + name_suffix must fit the 30-character account_id.
run "reject_too_long_name_suffix" {
  command = plan

  variables {
    name_suffix = "-way-too-long"
  }

  expect_failures = [var.name_suffix]
}
