module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 18.0"

  project_id   = var.project_id
  network_name = local.vpc_name
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${var.subnet_public_name}${var.name_suffix}"
      subnet_ip             = var.subnet_public_ip
      subnet_region         = var.region
      subnet_private_access = "false"
    },
    {
      subnet_name           = "${var.subnet_priv_a_name}${var.name_suffix}"
      subnet_ip             = var.subnet_priv_a_ip
      subnet_region         = var.region
      subnet_private_access = "true"
    },
    {
      subnet_name           = "${var.subnet_priv_b_name}${var.name_suffix}"
      subnet_ip             = var.subnet_priv_b_ip
      subnet_region         = var.region
      subnet_private_access = "true"
    }
  ]

  secondary_ranges = {
    "${var.subnet_priv_a_name}${var.name_suffix}" = [
      {
        range_name    = "secondary-range"
        ip_cidr_range = var.subnet_priv_a_secondary_ip
      }
    ],
    "${var.subnet_priv_b_name}${var.name_suffix}" = [
      {
        range_name    = "secondary-range"
        ip_cidr_range = var.subnet_priv_b_secondary_ip
      }
    ]
  }
}

resource "google_compute_router" "router" {
  name    = "gcp-sample-base-router${var.name_suffix}"
  project = var.project_id
  region  = var.region
  network = module.vpc.network_name
}

module "cloud_nat" {
  source  = "terraform-google-modules/cloud-nat/google"
  version = "~> 7.0"

  project_id                         = var.project_id
  region                             = var.region
  router                             = google_compute_router.router.name
  name                               = "gcp-sample-base-nat${var.name_suffix}"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

module "firewall_rules" {
  source  = "terraform-google-modules/network/google//modules/firewall-rules"
  version = "~> 18.0"

  project_id   = var.project_id
  network_name = module.vpc.network_name

  # The `rules` input names the source ranges `ranges` (`source_ranges` is an
  # ingress_rules attribute and is silently dropped here). An ingress rule
  # without any source applies to 0.0.0.0/0.
  rules = [
    {
      name        = "allow-iap-ssh${var.name_suffix}"
      description = "Allow SSH from IAP tunnel only (no public SSH)"
      direction   = "INGRESS"
      ranges      = ["35.235.240.0/20"]
      target_tags = []
      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
    },
    {
      name        = "allow-internal${var.name_suffix}"
      description = "Allow minimal internal traffic between subnets (least-privilege)"
      direction   = "INGRESS"
      # The VPC's own primary and secondary (GKE pods) ranges only, not all of
      # 10.0.0.0/8: Direct VPC egress of the Cloud Run samples draws from these
      # subnets too.
      ranges = [
        var.subnet_public_ip,
        var.subnet_priv_a_ip,
        var.subnet_priv_b_ip,
        var.subnet_priv_a_secondary_ip,
        var.subnet_priv_b_secondary_ip,
      ]
      target_tags = []
      allow = [
        {
          protocol = "icmp"
        },
        {
          protocol = "tcp"
          # Explicitly enumerate required ports only:
          #   22    — SSH (IAP backup path)
          #   443   — HTTPS (internal service calls, Private Google Access)
          #   5432  — PostgreSQL (Cloud SQL Auth Proxy to Cloud SQL via VPC peering)
          #   8080  — App/service default port
          #   8443  — App/service TLS port
          #   9090  — Cloud SQL Auth Proxy health check endpoint
          ports = ["22", "443", "5432", "8080", "8443", "9090"]
        }
      ]
    }
  ]
}
