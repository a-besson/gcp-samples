resource "google_service_account" "llm_sa" {
  account_id   = "llm-instance-sa"
  display_name = "LLM Instance Service Account"
  project      = var.project_id
}

# Minimum permissions to run and fetch drivers
resource "google_project_iam_member" "logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.llm_sa.email}"
}

resource "google_project_iam_member" "monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.llm_sa.email}"
}

resource "google_compute_instance" "llm_node" {
  name                      = "gemma-node"
  machine_type              = var.machine_type
  zone                      = var.zone
  project                   = var.project_id
  allow_stopping_for_update = true

  tags = ["llm-node"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 150 # Enough for OS + Docker + Gemma 27B
      type  = "pd-balanced"
    }
  }

  guest_accelerator {
    type  = var.gpu_type
    count = var.gpu_count
  }

  network_interface {
    network    = module.vpc.network_name
    subnetwork = module.vpc.subnets_names[0]
    # No public IP (Private IP only)
  }

  scheduling {
    preemptible         = var.is_spot
    automatic_restart   = !var.is_spot
    provisioning_model  = var.is_spot ? "SPOT" : "STANDARD"
    on_host_maintenance = "TERMINATE" # Required for GPUs
  }

  service_account {
    email  = google_service_account.llm_sa.email
    scopes = ["cloud-platform"]
  }

  # vTPM and integrity monitoring only: Secure Boot would refuse the NVIDIA
  # kernel modules installed by startup.sh, which are not signed (signing
  # needs a Machine Owner Key, see the cuda_installer documentation).
  shielded_instance_config {
    enable_secure_boot          = false
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # SSH keys come from OS Login (IAM) only, never from project metadata.
  metadata = {
    enable-oslogin         = "TRUE"
    block-project-ssh-keys = "TRUE"
  }

  metadata_startup_script = file("${path.module}/startup.sh")

  resource_policies = [google_compute_resource_policy.llm_schedule.self_link]
}
