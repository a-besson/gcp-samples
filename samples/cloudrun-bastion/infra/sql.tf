# --- Random suffix for the Cloud SQL instance name ---
# Instance names must be unique and cannot be reused for up to 7 days after deletion.
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# --- Cloud SQL Instance ---
resource "google_sql_database_instance" "postgres" {
  name             = "bastion-test-pg-${random_id.db_name_suffix.hex}"
  database_version = "POSTGRES_15"
  region           = var.region
  project          = var.project_id

  # Deletion protection disabled to allow easy tear down for the sample
  deletion_protection = false

  settings {
    # Low-cost tier suitable for testing
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = true
      private_network = data.terraform_remote_state.base.outputs.network_self_link
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# --- Database ---
resource "google_sql_database" "database" {
  name     = "testdb"
  instance = google_sql_database_instance.postgres.name
  project  = var.project_id
}

# --- Database User ---
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_sql_user" "users" {
  name     = "testuser"
  instance = google_sql_database_instance.postgres.name
  project  = var.project_id
  password = random_password.db_password.result
}
