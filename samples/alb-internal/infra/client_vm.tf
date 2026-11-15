locals {
  client_vm_zone = "${var.region}-b"
}

resource "google_compute_instance" "client" {
  name                      = "alb-internal-client${var.name_suffix}"
  project                   = var.project_id
  zone                      = local.client_vm_zone
  machine_type              = "e2-micro"
  allow_stopping_for_update = true

  boot_disk {
    kms_key_self_link = data.terraform_remote_state.bootstrap.outputs.kms_key_compute
    initialize_params {
      image = "debian-cloud/debian-13"
      size  = 10
    }
  }

  # No access_config block: no public IP. Reached only via
  # `gcloud compute ssh --tunnel-through-iap`.
  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.isolated.id
  }

  service_account {
    email  = google_service_account.client_vm.email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  metadata = {
    enable-oslogin         = "TRUE"
    block-project-ssh-keys = "TRUE"
  }

  depends_on = [module.project_services]
}
