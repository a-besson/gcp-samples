output "load_balancer_ip" {
  description = "Static IP of the HTTPS Load Balancer. Create a DNS A record pointing var.domain to this address."
  value       = google_compute_global_address.bastion_ip.address
}

output "bastion_url" {
  description = "HTTPS URL of the Cloud Run bastion proxy (after DNS propagation and SSL provisioning)."
  value       = "https://${var.domain}"
}

output "cloud_run_service_url" {
  description = "Internal URL of the Cloud Run bastion service."
  value       = google_cloud_run_v2_service.bastion.uri
}

output "db_private_ip" {
  description = "The private IP address of the Cloud SQL instance."
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "db_password" {
  description = "The auto-generated password for the testuser in Cloud SQL."
  value       = random_password.db_password.result
  sensitive   = true
}

output "proxy_test_commands" {
  description = "Shell commands to use the SOCKS5 bastion proxy via IAP tunnel to connect to the database."
  sensitive   = true
  value       = <<-EOT

    # ── Step 1: Open an IAP-authenticated tunnel to the Cloud Run service ──
    gcloud run services proxy cloudrun-bastion \
      --project=${var.project_id} \
      --region=${var.region} \
      --port=1080

    # ── Step 2 (new terminal): Connect to Cloud SQL via the SOCKS5 proxy ──
    # The Cloud SQL instance only has a private IP. The proxy forwards traffic inside the VPC.
    export PGPASSWORD="${random_password.db_password.result}"
    psql -h localhost -p 1080 -U testuser testdb

    # Note: Depending on your psql version, you might need an external tool to wrap socks5 (e.g., tsocks / proxychains)
    # Alternatively, you can use curl to test a raw TCP connection:
    curl --socks5-hostname localhost:1080 http://${google_sql_database_instance.postgres.private_ip_address}:5432

  EOT
}
