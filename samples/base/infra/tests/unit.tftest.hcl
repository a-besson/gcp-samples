# 100% offline unit tests: mock_provider replaces every google/google-beta
# API call, so this file runs in CI with zero GCP credentials
# (`task test` = `terraform init -backend=false` + `terraform test`).
# Checks that need the real API (assigned gateway address, effective labels)
# live in `task e2e`, against the deployed stack.

# Mocked apply runs (still offline) make computed attributes known. Only
# values the provider validates get realistic defaults.
mock_provider "google" {
  mock_resource "google_service_account" {
    defaults = {
      name  = "projects/test-project/serviceAccounts/mock-sa@test-project.iam.gserviceaccount.com"
      email = "mock-sa@test-project.iam.gserviceaccount.com"
    }
  }
}
mock_provider "google-beta" {}

variables {
  project_id  = "test-project"
  region      = "europe-west9"
  name_suffix = "-test"
}

run "validate_vpc" {
  command = apply

  assert {
    condition     = module.vpc.network_name == "gcp-sample-base-vpc${var.name_suffix}"
    error_message = "VPC name did not match expected value"
  }

  assert {
    condition     = length(module.vpc.subnets) == 3
    error_message = "Expected 3 subnets to be created"
  }
}

run "validate_subnets" {
  command = apply

  assert {
    condition     = module.vpc.subnets["europe-west9/subnet-public${var.name_suffix}"].ip_cidr_range == "10.0.0.0/22"
    error_message = "Public subnet CIDR did not match expected value"
  }

  assert {
    condition     = module.vpc.subnets["europe-west9/subnet-priv-a${var.name_suffix}"].ip_cidr_range == "10.0.4.0/22"
    error_message = "Private subnet A CIDR did not match expected value"
  }

  assert {
    condition     = module.vpc.subnets["europe-west9/subnet-priv-b${var.name_suffix}"].ip_cidr_range == "10.0.20.0/22"
    error_message = "Private subnet B CIDR did not match expected value"
  }

  assert {
    condition     = module.vpc.subnets["europe-west9/subnet-priv-a${var.name_suffix}"].private_ip_google_access == true
    error_message = "Private subnet A should have private Google access enabled"
  }

  assert {
    condition     = module.vpc.subnets["europe-west9/subnet-priv-a${var.name_suffix}"].secondary_ip_range[0].range_name == "secondary-range" && module.vpc.subnets["europe-west9/subnet-priv-a${var.name_suffix}"].secondary_ip_range[0].ip_cidr_range == "100.64.0.0/22"
    error_message = "Private subnet A secondary IP range did not match expected value"
  }

  assert {
    condition     = module.vpc.subnets["europe-west9/subnet-priv-b${var.name_suffix}"].secondary_ip_range[0].range_name == "secondary-range" && module.vpc.subnets["europe-west9/subnet-priv-b${var.name_suffix}"].secondary_ip_range[0].ip_cidr_range == "100.64.4.0/22"
    error_message = "Private subnet B secondary IP range did not match expected value"
  }
}

run "validate_services" {
  command = apply

  assert {
    condition     = google_project_service.container_scanning.service == "containerscanning.googleapis.com"
    error_message = "Container scanning service ID did not match"
  }

  assert {
    condition     = google_project_service.artifact_registry.service == "artifactregistry.googleapis.com"
    error_message = "Artifact Registry service ID did not match"
  }

  assert {
    condition     = google_project_service.compute.service == "compute.googleapis.com"
    error_message = "Compute service ID did not match"
  }

  assert {
    condition     = google_project_service.iam.service == "iam.googleapis.com"
    error_message = "IAM service ID did not match"
  }
}

run "validate_network_infrastructure" {
  command = apply

  # Offline, the router keeps the configured network (the API stores its
  # self link): compare with the VPC name the module created.
  assert {
    condition     = google_compute_router.router.network == module.vpc.network_name
    error_message = "Cloud Router is not attached to the correct VPC"
  }

  assert {
    condition     = length(module.firewall_rules.firewall_rules) == 2
    error_message = "Expected exactly two firewall rules from the module"
  }

  # An ingress rule without a source range applies to 0.0.0.0/0.
  assert {
    condition     = module.firewall_rules.firewall_rules["allow-iap-ssh${var.name_suffix}"].source_ranges == toset(["35.235.240.0/20"])
    error_message = "allow-iap-ssh must only admit the IAP TCP forwarding range"
  }

  assert {
    condition     = module.firewall_rules.firewall_rules["allow-internal${var.name_suffix}"].source_ranges == toset(["10.0.0.0/22", "10.0.4.0/22", "10.0.20.0/22", "100.64.0.0/22", "100.64.4.0/22"])
    error_message = "allow-internal must only admit the VPC's own subnet ranges (no 10.0.0.0/8)"
  }
}

run "validate_compute_test_vms" {
  command = apply

  assert {
    condition     = google_service_account.test_vm_sa.account_id == "test-vm-sa${var.name_suffix}"
    error_message = "Test VM Service Account ID did not match"
  }

  assert {
    condition     = google_compute_instance.test_vm_a.name == "vm-test-a${var.name_suffix}"
    error_message = "Test VM A name is incorrect"
  }

  assert {
    condition     = google_compute_instance.test_vm_b.name == "vm-test-b${var.name_suffix}"
    error_message = "Test VM B name is incorrect"
  }

  assert {
    condition     = google_compute_instance.test_vm_a.metadata.enable-oslogin == "TRUE"
    error_message = "OS Login should be enabled on Test VM A"
  }

  assert {
    condition     = alltrue([for vm in [google_compute_instance.test_vm_a, google_compute_instance.test_vm_b] : vm.metadata.block-project-ssh-keys == "TRUE" && vm.shielded_instance_config[0].enable_secure_boot])
    error_message = "Test VMs must block project-wide SSH keys and boot with Shielded VM Secure Boot"
  }

  assert {
    condition     = contains(google_compute_instance.test_vm_a.tags, "dev")
    error_message = "Test VM A does not have the 'dev' tag"
  }
}
