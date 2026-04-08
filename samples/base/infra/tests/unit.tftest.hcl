# Variables are now loaded from ../../.env via Task
# We add a unique suffix for testing to avoid naming conflicts (Error 409)
variables {
  name_suffix = "-test-${formatdate("hhmmss", timestamp())}"
}

run "validate_vpc" {
  command = plan

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
  command = plan

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
  command = plan

  assert {
    condition     = google_project_service.container_scanning.service == "containerscanning.googleapis.com"
    error_message = "Container scanning service ID did not match"
  }
}

run "validate_apply" {
  command = apply

  assert {
    condition     = module.vpc.subnets["europe-west9/subnet-public${var.name_suffix}"].gateway_address == "10.0.0.1"
    error_message = "End-to-end validation failed: Public subnet gateway address '10.0.0.1' was not correctly assigned by GCP"
  }
}

run "validate_network_infrastructure" {
  command = plan

  assert {
    condition     = google_compute_router.router.network == module.vpc.network_self_link
    error_message = "Cloud Router is not attached to the correct VPC"
  }

  assert {
    condition     = length(module.firewall_rules.firewall_rules) == 2
    error_message = "Expected exactly two firewall rules from the module"
  }
}

run "validate_compute_test_vms" {
  command = plan

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
    condition     = google_compute_instance.test_vm_public.name == "vm-test-public${var.name_suffix}"
    error_message = "Test VM Public name is incorrect"
  }

  assert {
    condition     = google_compute_instance.test_vm_public.labels.env == "dev"
    error_message = "Test VM Public does not have the 'env=dev' label"
  }

  assert {
    condition     = contains(google_compute_instance.test_vm_public.tags, "dev")
    error_message = "Test VM Public does not have the 'dev' tag"
  }
}
