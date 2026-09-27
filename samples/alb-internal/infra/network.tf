# --- VPC ---
# Standalone VPC, dedicated to this sample (no dependency on samples/base).
resource "google_compute_network" "vpc" {
  name                    = "alb-internal-vpc${var.name_suffix}"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  depends_on              = [module.project_services]
}

# --- subnet-isolated ---
# Hosts the client VM and the ILB forwarding rule VIP.
resource "google_compute_subnetwork" "isolated" {
  name                     = "subnet-isolated${var.name_suffix}"
  ip_cidr_range            = var.vpc_cidr_isolated
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

# --- subnet-isolated-application ---
# Hosts the Cloud Run Direct VPC Egress NIC and the Cloud SQL PSC endpoint.
resource "google_compute_subnetwork" "application" {
  name                     = "subnet-isolated-application${var.name_suffix}"
  ip_cidr_range            = var.vpc_cidr_application
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

# --- subnet-proxy-only ---
# Mandatory for a regional internal Application Load Balancer: the managed
# Envoy proxies live here. It carries no application workload.
resource "google_compute_subnetwork" "proxy_only" {
  name          = "subnet-proxy-only${var.name_suffix}"
  ip_cidr_range = var.vpc_cidr_proxy_only
  region        = var.region
  network       = google_compute_network.vpc.id
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}
