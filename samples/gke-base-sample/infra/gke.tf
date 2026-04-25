# --- GKE Autopilot Private Cluster ---
# Uses the official terraform-google-modules/kubernetes-engine submodule
# for Autopilot private clusters with best-practice defaults.

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  version = "~> 36.0"

  project_id = var.project_id
  name       = "${var.cluster_name}${var.name_suffix}"
  region     = var.region
  network    = data.terraform_remote_state.base.outputs.network_name
  subnetwork = data.terraform_remote_state.base.outputs.subnet_priv_a.name

  # Pod and service IP allocation
  ip_range_pods     = "secondary-range"
  ip_range_services = null

  # Private cluster configuration
  enable_private_nodes    = true
  enable_private_endpoint = false
  master_ipv4_cidr_block  = "172.16.0.0/28"

  # Master authorized networks - restrict control plane access
  # Only nodes subnet and IAP range are allowed
  master_authorized_networks = concat(
    [
      {
        cidr_block   = data.terraform_remote_state.base.outputs.subnet_priv_a.ip_cidr_range
        display_name = "subnet-priv-a"
      },
      {
        cidr_block   = "35.235.240.0/20"
        display_name = "IAP-tunnel"
      }
    ],
    var.master_authorized_networks
  )
  master_global_access_enabled = true

  # Release channel and version
  release_channel    = "REGULAR"
  kubernetes_version = "latest"

  # Security best practices
  enable_vertical_pod_autoscaling = true
  horizontal_pod_autoscaling      = true
  http_load_balancing             = true
  dns_cache                       = true
  service_external_ips            = false
  deletion_protection             = false
  create_service_account          = true
  grant_registry_access           = true

  # Security posture
  security_posture_mode               = "BASIC"
  security_posture_vulnerability_mode = "VULNERABILITY_BASIC"

  # Maintenance window: weekdays 02:00-06:00 UTC
  maintenance_start_time = "02:00"

  # Network tags for firewall alignment with base
  network_tags = ["dev"]

  cluster_resource_labels = {
    env     = "dev"
    sample  = "gke-base-sample"
    cluster = "autopilot"
  }

  depends_on = [module.project_services]
}
