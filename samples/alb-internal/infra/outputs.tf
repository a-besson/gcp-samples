output "api_url" {
  description = "The internal HTTPS URL of the API, reachable only from inside the VPC (or via the client VM)."
  value       = "https://${local.api_host}"
}

output "api_host" {
  description = "The internal DNS hostname of the API (used by the e2e tests to build the Host header / URL)."
  value       = local.api_host
}

output "forwarding_rule_ip" {
  description = "The internal VIP address of the ALB forwarding rule."
  value       = google_compute_forwarding_rule.api.ip_address
}

output "client_vm_name" {
  description = "The name of the client VM, for `gcloud compute ssh`."
  value       = google_compute_instance.client.name
}

output "client_vm_zone" {
  description = "The zone of the client VM, for `gcloud compute ssh`."
  value       = local.client_vm_zone
}

output "cloud_run_service_name" {
  description = "The name of the Cloud Run API service."
  value       = google_cloud_run_v2_service.api.name
}

output "cloud_sql_connection_name" {
  description = "The Cloud SQL instance connection name, for use with the Cloud SQL Auth Proxy."
  value       = google_sql_database_instance.app.connection_name
}

output "vpc_network_name" {
  description = "The name of the VPC network."
  value       = google_compute_network.vpc.name
}
