module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 18.0"

  project_id   = var.project_id
  network_name = "llm-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "llm-subnet"
      subnet_ip             = "10.0.4.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
    }
  ]
}

# Cloud NAT for downloading drivers and models
module "cloud_nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "~> 7.0"
  project_id    = var.project_id
  region        = var.region
  router        = "llm-router"
  name          = "llm-nat"
  create_router = true
  network       = module.vpc.network_name
}

# Firewall for IAP (SSH)
resource "google_compute_firewall" "allow_iap" {
  name    = "allow-iap-ssh-api"
  network = module.vpc.network_name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22", "11434"]
  }

  source_ranges = ["35.235.240.0/20"] # IAP IP range
  target_tags   = ["llm-node"]
}
