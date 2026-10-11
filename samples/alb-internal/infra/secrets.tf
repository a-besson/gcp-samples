# Only the DB password is stored — never a full connection string, so a
# leaked secret cannot be replayed without also knowing the DB name/host.
resource "google_secret_manager_secret" "db_password" {
  secret_id = "alb-internal-db-password${var.name_suffix}"
  project   = var.project_id

  replication {
    user_managed {
      replicas {
        location = var.region
        customer_managed_encryption {
          kms_key_name = data.terraform_remote_state.bootstrap.outputs.kms_key_secrets
        }
      }
    }
  }

  depends_on = [module.project_services]
}

# Gotcha: random_password.db lives in the Terraform state (GCS-encrypted).
# Documented in Security Design; a production deployment would seed this
# out-of-band instead.
resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db.result
}
