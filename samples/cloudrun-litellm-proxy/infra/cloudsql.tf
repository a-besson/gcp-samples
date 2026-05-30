resource "random_password" "db_password" {
  length  = 32
  special = false
}

# Private service connection: allocates a /20 block in the base VPC for Google
# managed services (Cloud SQL). Create this once per VPC; if another sample
# already created it, import it with `terraform import`.
resource "google_compute_global_address" "private_ip_range" {
  name          = "litellm-private-ip${var.name_suffix}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = data.terraform_remote_state.base.outputs.network_self_link
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = data.terraform_remote_state.base.outputs.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]

  depends_on = [module.project_services]
}

module "cloudsql" {
  source  = "terraform-google-modules/sql-db/google//modules/postgresql"
  version = "~> 22.0"

  name             = "litellm-db${var.name_suffix}"
  database_version = "POSTGRES_15"
  project_id       = var.project_id
  zone             = "${var.region}-a"
  region           = var.region
  tier             = var.cloudsql_tier

  # Keep false for samples to allow `task destroy` without manual intervention.
  # Set to true in production environments.
  deletion_protection = false

  # Security: enforce TLS for all client connections. The Cloud SQL Auth Proxy
  # sidecar always connects over an encrypted mTLS tunnel, so this is safe.
  ip_configuration = {
    ipv4_enabled        = false
    private_network     = data.terraform_remote_state.base.outputs.network_self_link
    allocated_ip_range  = google_compute_global_address.private_ip_range.name
    authorized_networks = []
    require_ssl         = true
    ssl_mode            = "ENCRYPTED_ONLY"
  }

  # Security & audit: PostgreSQL flags for connection tracing and lock monitoring.
  database_flags = [
    {
      name  = "cloudsql.iam_authentication"
      value = "on"
    },
    {
      name  = "log_connections"
      value = "on"
    },
    {
      name  = "log_disconnections"
      value = "on"
    },
    {
      name  = "log_lock_waits"
      value = "on"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000" # Log queries slower than 1s
    }
  ]

  # Automated daily backups: 7-day retention + PITR for disaster recovery.
  backup_configuration = {
    enabled                        = true
    start_time                     = "03:00"
    location                       = var.region
    point_in_time_recovery_enabled = true
    retained_backups               = 7
    retention_unit                 = "COUNT"
    transaction_log_retention_days = 7
  }

  # Maintenance window: Sunday at 3:00 AM UTC (low-traffic window).
  maintenance_window_day          = 7
  maintenance_window_hour         = 3
  maintenance_window_update_track = "stable"

  # Query insights: enables slow query analysis and execution plan sampling.
  insights_config = {
    query_insights_enabled  = true
    query_plans_per_minute  = 5
    query_string_length     = 1024
    record_application_tags = true
    record_client_address   = false # Privacy: do not log client IPs
  }

  additional_databases = [
    {
      name      = "litellm"
      charset   = "UTF8"
      collation = "en_US.UTF8"
    }
  ]

  additional_users = [
    {
      name            = "litellm"
      password        = random_password.db_password.result
      host            = ""
      random_password = false
      type            = "BUILT_IN"
    }
  ]

  depends_on = [google_service_networking_connection.private_vpc_connection]
}
