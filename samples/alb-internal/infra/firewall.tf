# --- Deny-by-default model ---
# Nothing is implicitly allowed: every flow below is an explicit, commented
# exception carved out of these two low-priority deny-all rules.

resource "google_compute_firewall" "deny_all_ingress" {
  name      = "alb-internal-deny-all-ingress${var.name_suffix}"
  network   = google_compute_network.vpc.id
  direction = "INGRESS"
  priority  = 65533
  deny {
    protocol = "all"
  }
  source_ranges = ["0.0.0.0/0"]
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "deny_all_egress" {
  name      = "alb-internal-deny-all-egress${var.name_suffix}"
  network   = google_compute_network.vpc.id
  direction = "EGRESS"
  priority  = 65533
  deny {
    protocol = "all"
  }
  destination_ranges = ["0.0.0.0/0"]
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# --- allow-iap-ssh ---
# Lets the IAP TCP forwarding proxy (fixed Google-owned range) reach the
# client VM's SSH port. Scoped to the VM's own service account, not the
# whole network, since `target_service_accounts` is only honored for VM NICs.
resource "google_compute_firewall" "allow_iap_ssh" {
  name      = "alb-internal-allow-iap-ssh${var.name_suffix}"
  network   = google_compute_network.vpc.id
  direction = "INGRESS"
  priority  = 1000
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges           = ["35.235.240.0/20"]
  target_service_accounts = [google_service_account.client_vm.email]
}

# --- allow-client-to-ilb ---
# Lets the client VM reach the internal ALB's VIP (subnet-isolated) over
# HTTPS, to run the smoke test.
resource "google_compute_firewall" "allow_client_to_ilb" {
  name      = "alb-internal-allow-client-to-ilb${var.name_suffix}"
  network   = google_compute_network.vpc.id
  direction = "EGRESS"
  priority  = 1000
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  destination_ranges      = [var.vpc_cidr_isolated]
  target_service_accounts = [google_service_account.client_vm.email]
}

# --- allow-run-to-sql ---
# Cloud Run in Direct VPC Egress does not attach a service account to its
# NIC, so `target_service_accounts` cannot scope this rule: a network tag is
# the only per-workload selector available (the "or network" fallback from
# the request). Destination is the single PSC endpoint IP, not the whole
# application subnet. Port 3307, not 5432: the cloud-sql-proxy sidecar's
# `--psc` mode dials the PSC endpoint over the proxy's own encrypted tunnel
# port, and only exposes 5432 locally to the api container (cloudrun.tf).
resource "google_compute_firewall" "allow_run_to_sql" {
  name      = "alb-internal-allow-run-to-sql${var.name_suffix}"
  network   = google_compute_network.vpc.id
  direction = "EGRESS"
  priority  = 1000
  allow {
    protocol = "tcp"
    ports    = ["3307"]
  }
  destination_ranges = ["${google_compute_address.sql_psc.address}/32"]
  target_tags        = ["alb-internal-api"]
}
