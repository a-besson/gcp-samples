# --- Unit tests for GKE Autopilot ---
# 100% offline unit tests: mock_provider replaces every google/google-beta
# API call, so this file runs in CI with zero GCP credentials
# (`task test` = `terraform init -backend=false` + `terraform test`).

# Mocked apply runs (still offline) make the module's computed outputs known;
# only values the provider or the module validates get realistic defaults.
mock_provider "google" {
  mock_data "google_compute_zones" {
    defaults = { names = ["europe-west1-b", "europe-west1-c", "europe-west1-d"] }
  }
  mock_resource "google_service_account" {
    defaults = {
      name   = "projects/test-project/serviceAccounts/mock-sa@test-project.iam.gserviceaccount.com"
      email  = "mock-sa@test-project.iam.gserviceaccount.com"
      member = "serviceAccount:mock-sa@test-project.iam.gserviceaccount.com"
    }
  }
}
mock_provider "google-beta" {
  mock_data "google_compute_zones" {
    defaults = { names = ["europe-west1-b", "europe-west1-c", "europe-west1-d"] }
  }
  mock_resource "google_service_account" {
    defaults = {
      name   = "projects/test-project/serviceAccounts/mock-sa@test-project.iam.gserviceaccount.com"
      email  = "mock-sa@test-project.iam.gserviceaccount.com"
      member = "serviceAccount:mock-sa@test-project.iam.gserviceaccount.com"
    }
  }
}

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
  project_id  = "test-project"
  region      = "europe-west1"
  name_suffix = "-test"
}

# The cluster name comes from the API-computed cluster id (module output
# `name`): it is checked against the deployed cluster by `task e2e`.
run "validate_gke_cluster" {
  command = apply

  assert {
    condition     = module.gke.location == var.region
    error_message = "The Autopilot cluster must be regional, in var.region."
  }

  assert {
    condition     = contains(flatten([for m in module.gke.master_authorized_networks_config : [for c in m.cidr_blocks : c.cidr_block]]), "10.0.4.0/22")
    error_message = "The nodes subnet (subnet-priv-a) must be a master authorized network."
  }

  assert {
    condition     = !contains(flatten([for m in module.gke.master_authorized_networks_config : [for c in m.cidr_blocks : c.cidr_block]]), "35.235.240.0/20")
    error_message = "The shared IAP TCP forwarding range must not be a master authorized network."
  }
}

run "validate_apis" {
  command = apply

  assert {
    condition     = contains(module.project_services.enabled_apis, "container.googleapis.com")
    error_message = "Container API should be enabled"
  }

  assert {
    condition     = contains(module.project_services.enabled_apis, "compute.googleapis.com")
    error_message = "Compute API should be enabled"
  }
}

run "validate_network_reference" {
  command = apply

  assert {
    condition     = data.terraform_remote_state.base.outputs.network_name != ""
    error_message = "Base network name should not be empty"
  }

  assert {
    condition     = data.terraform_remote_state.base.outputs.subnet_priv_a.name != ""
    error_message = "Subnet priv-a name should not be empty"
  }
}
