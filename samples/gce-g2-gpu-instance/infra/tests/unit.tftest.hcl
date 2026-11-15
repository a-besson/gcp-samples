# 100% offline unit tests: mock_provider replaces every google/google-beta
# API call, so this file runs in CI with zero GCP credentials
# (`task test` = `terraform init -backend=false` + `terraform test`).

mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project"
  region     = "europe-west4"
  zone       = "europe-west4-a"
}

run "validate_gpu_vm" {
  command = plan

  assert {
    condition     = startswith(google_compute_instance.llm_node.zone, "${var.region}-")
    error_message = "The VM zone must belong to var.region (subnet and start/stop policy live there)."
  }

  assert {
    condition     = length(google_compute_instance.llm_node.network_interface[0].access_config) == 0
    error_message = "The GPU VM must have no public IP (IAP only)."
  }

  assert {
    condition     = google_compute_instance.llm_node.scheduling[0].on_host_maintenance == "TERMINATE"
    error_message = "GPU VMs must terminate on host maintenance."
  }
}

run "validate_iap_only_ingress" {
  command = plan

  assert {
    condition     = google_compute_firewall.allow_iap.source_ranges == toset(["35.235.240.0/20"]) && google_compute_firewall.allow_iap.target_tags == toset(["llm-node"])
    error_message = "SSH and the Ollama API must only be reachable from the IAP TCP forwarding range, on the llm-node tag."
  }
}
