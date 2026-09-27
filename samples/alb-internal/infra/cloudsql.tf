# Instance names cannot be reused for up to 7 days after deletion.
resource "random_id" "db" {
  byte_length = 4
}

# Raw resource (not the sql-db module): psc_config and encryption_key_name
# need to be set precisely, which the module does not expose together.
resource "google_sql_database_instance" "app" {
  name                = "alb-internal-pg${var.name_suffix}-${random_id.db.hex}"
  database_version    = "POSTGRES_17"
  region              = var.region
  project             = var.project_id
  encryption_key_name = data.terraform_remote_state.bootstrap.outputs.kms_key_sql
  deletion_protection = false # sample: must be destroyable without manual steps

  settings {
    edition           = "ENTERPRISE" # ENTERPRISE_PLUS (the API default) rejects shared-core tiers like db-f1-micro
    tier              = var.db_tier
    availability_type = "ZONAL"
    disk_size         = 10
    disk_autoresize   = false # FinOps guard-rail: no silent disk growth

    # KICS false positives below: it only recognizes the legacy
    # `private_network` attribute (not `psc_config`) for private connectivity,
    # and only the deprecated `require_ssl` attribute (not `ssl_mode`) for
    # SSL enforcement. ipv4_enabled=false + psc_config already makes this
    # instance private, and ssl_mode=ENCRYPTED_ONLY already enforces TLS.
    # kics-scan ignore-block
    ip_configuration {
      ipv4_enabled = false # no public IP
      ssl_mode     = "ENCRYPTED_ONLY"
      psc_config {
        psc_enabled               = true
        allowed_consumer_projects = [var.project_id]
      }
    }

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }
    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    user_labels = {
      role = "alb-internal-database"
    }
  }

  depends_on = [module.project_services]
}

# --- PSC endpoint, inside subnet-isolated-application ---
# This is what literally places the database's private connectivity point
# inside the requested subnet (Private Service Access would instead place
# the instance in a peered range outside the VPC).
resource "google_compute_address" "sql_psc" {
  name         = "alb-internal-sql-psc${var.name_suffix}"
  subnetwork   = google_compute_subnetwork.application.id
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_forwarding_rule" "sql_psc" {
  name                  = "alb-internal-sql-psc${var.name_suffix}"
  region                = var.region
  network               = google_compute_network.vpc.id
  ip_address            = google_compute_address.sql_psc.self_link
  load_balancing_scheme = "" # empty string is mandatory for a PSC endpoint
  target                = google_sql_database_instance.app.psc_service_attachment_link
}

resource "google_dns_managed_zone" "sql" {
  name       = "alb-internal-sql${var.name_suffix}"
  dns_name   = "${var.region}.sql.goog."
  visibility = "private"
  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc.id
    }
  }
}

resource "google_dns_record_set" "sql" {
  name         = google_sql_database_instance.app.dns_name # already trailing-dot terminated
  managed_zone = google_dns_managed_zone.sql.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.sql_psc.address]
}

resource "google_sql_database" "app" {
  name     = "appdb"
  instance = google_sql_database_instance.app.name
  project  = var.project_id
}

# Built-in DB user (not IAM DB auth): Flyway needs to own/create the public
# schema, which an IAM-authenticated user does not by default on PG15+.
resource "random_password" "db" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_sql_user" "app" {
  name     = "appuser"
  instance = google_sql_database_instance.app.name
  project  = var.project_id
  password = random_password.db.result
}
