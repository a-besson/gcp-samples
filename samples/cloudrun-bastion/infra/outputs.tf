output "bastion_url" {
  description = "The HTTPS URL for the Cloud Run Bastion (secured by IAP)."
  value       = "https://${local.domain}"
}

output "load_balancer_ip" {
  description = "The external IP address of the Global Load Balancer."
  value       = module.lb_http.external_ip
}

output "cloud_run_uri" {
  description = "The auto-generated Cloud Run URI (internal use only)."
  value       = google_cloud_run_v2_service.bastion.uri
}

output "service_account_email" {
  description = "The email of the Cloud Run Bastion Service Account."
  value       = google_service_account.bastion_sa.email
}

output "db_instance_ip" {
  description = "The private IP address of the Cloud SQL instance."
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "db_password" {
  description = "The auto-generated password for the test user."
  value       = random_password.db_password.result
  sensitive   = true
}

output "db_instance_connection_name" {
  description = "The connection name of the Cloud SQL instance for use with Cloud SQL Auth Proxy."
  value       = google_sql_database_instance.postgres.connection_name
}
