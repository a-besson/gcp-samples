resource "google_service_account" "test_vm_sa" {
  account_id   = "test-vm-sa${var.name_suffix}"
  display_name = "Service Account for Network Test VMs"
  project      = var.project_id
}

resource "google_project_iam_member" "test_vm_logging" {
  project    = var.project_id
  role       = "roles/logging.logWriter"
  member     = "serviceAccount:${google_service_account.test_vm_sa.email}"
  depends_on = [google_project_service.cloudresourcemanager]
}

resource "google_project_iam_member" "test_vm_monitoring" {
  project    = var.project_id
  role       = "roles/monitoring.metricWriter"
  member     = "serviceAccount:${google_service_account.test_vm_sa.email}"
  depends_on = [google_project_service.cloudresourcemanager]
}

resource "google_project_iam_member" "test_vm_storage" {
  project    = var.project_id
  role       = "roles/storage.objectViewer"
  member     = "serviceAccount:${google_service_account.test_vm_sa.email}"
  depends_on = [google_project_service.cloudresourcemanager]
}

resource "google_compute_instance" "test_vm_a" {
  project      = var.project_id
  name         = "vm-test-a${var.name_suffix}"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"

  tags = ["dev"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = module.vpc.subnets["${var.region}/${var.subnet_priv_a_name}${var.name_suffix}"].self_link
  }

  service_account {
    email  = google_service_account.test_vm_sa.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_instance" "test_vm_b" {
  project      = var.project_id
  name         = "vm-test-b${var.name_suffix}"
  machine_type = "e2-micro"
  zone         = "${var.region}-b"

  tags = ["dev"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = module.vpc.subnets["${var.region}/${var.subnet_priv_b_name}${var.name_suffix}"].self_link
  }

  service_account {
    email  = google_service_account.test_vm_sa.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
}
