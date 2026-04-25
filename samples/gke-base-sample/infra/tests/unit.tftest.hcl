# --- Unit / Plan Tests for GKE Autopilot ---
# Variables are loaded from ../../.env via Task
# We add a unique suffix for testing to avoid naming conflicts (Error 409)

variables {
  name_suffix = "-test-${formatdate("hhmmss", timestamp())}"
}

run "validate_gke_cluster_plan" {
  command = plan

  assert {
    condition     = module.gke.name == "gke-autopilot${var.name_suffix}"
    error_message = "GKE cluster name did not match expected value"
  }
}

run "validate_apis" {
  command = plan

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
  command = plan

  assert {
    condition     = data.terraform_remote_state.base.outputs.network_name != ""
    error_message = "Base network name should not be empty"
  }

  assert {
    condition     = data.terraform_remote_state.base.outputs.subnet_priv_a.name != ""
    error_message = "Subnet priv-a name should not be empty"
  }
}
