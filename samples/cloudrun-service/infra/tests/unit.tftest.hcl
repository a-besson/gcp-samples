# 100% offline unit tests: mock_provider replaces every google/google-beta
# API call, so this file runs in CI with zero GCP credentials
# (`task test` = `terraform init -backend=false` + `terraform test`).
# The HTTP checks (403 without a token, 200 with one) run against the
# deployed services in `task e2e`.

mock_provider "google" {}
mock_provider "google-beta" {}

# Outputs read from the base stack (GCS remote state) in a real plan.
override_data {
  target = data.terraform_remote_state.base
  values = {
    outputs = {
      network_name  = "gcp-sample-base-vpc-test"
      subnet_public = { id = "projects/test-project/regions/europe-west1/subnetworks/subnet-public-test", name = "subnet-public-test", ip_cidr_range = "10.0.0.0/22" }
      subnet_priv_a = { id = "projects/test-project/regions/europe-west1/subnetworks/subnet-priv-a-test", name = "subnet-priv-a-test", ip_cidr_range = "10.0.4.0/22" }
    }
  }
}

variables {
  project_id    = "test-project"
  region        = "europe-west1"
  name_suffix   = "-test"
  image_service = "europe-west1-docker.pkg.dev/test-project/cloudrun-simple-service-test/service:latest"
}

run "validate_ingress" {
  command = plan

  assert {
    condition     = google_cloud_run_v2_service.exposed_service.ingress == "INGRESS_TRAFFIC_ALL"
    error_message = "exposed-service must accept traffic from the internet (IAM still required)."
  }

  assert {
    condition     = google_cloud_run_v2_service.internal_service.ingress == "INGRESS_TRAFFIC_INTERNAL_ONLY"
    error_message = "internal-service must only accept internal traffic."
  }

  assert {
    condition     = google_cloud_run_v2_service.internal_service.template[0].vpc_access[0].egress == "PRIVATE_RANGES_ONLY"
    error_message = "internal-service must only route private ranges through the VPC."
  }
}

run "validate_authenticated_only" {
  command = plan

  assert {
    condition     = google_cloud_run_v2_service_iam_member.test_sa_invoker.role == "roles/run.invoker" && startswith(google_cloud_run_v2_service_iam_member.test_sa_invoker.member, "serviceAccount:")
    error_message = "The tester service account must be granted roles/run.invoker on exposed-service."
  }
}

# The managed certificate lives inside module.lb_http (not addressable from a
# test): check the Cloud Endpoints domain it is issued for instead.
run "validate_https_load_balancer" {
  command = plan

  assert {
    condition     = google_endpoints_service.lb_dns.service_name == "exposed-service${var.name_suffix}.endpoints.${var.project_id}.cloud.goog"
    error_message = "The Cloud Endpoints domain (used by the managed certificate) must follow exposed-service<name_suffix>.endpoints.<project>.cloud.goog."
  }

  assert {
    condition     = output.load_balancer_url == "https://${google_endpoints_service.lb_dns.service_name}"
    error_message = "The Load Balancer must be reached over HTTPS on the Cloud Endpoints domain."
  }
}

run "validate_names" {
  command = plan

  assert {
    condition     = google_cloud_run_v2_service.exposed_service.name == "exposed-service${var.name_suffix}" && google_cloud_run_v2_service.internal_service.name == "internal-service${var.name_suffix}"
    error_message = "Service names must carry name_suffix."
  }
}

run "reject_invalid_name_suffix" {
  command = plan

  variables {
    name_suffix = "_Test"
  }

  expect_failures = [var.name_suffix]
}
