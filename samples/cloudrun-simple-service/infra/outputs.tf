output "exposed_service_url" {
  description = "The auto-generated Cloud Run URL for the service"
  value       = google_cloud_run_v2_service.exposed_service.uri
}

output "exposed_service_name" {
  description = "The name of the service"
  value       = google_cloud_run_v2_service.exposed_service.name
}

output "internal_service_url" {
  description = "The auto-generated Cloud Run URL for the internal service"
  value       = google_cloud_run_v2_service.internal_service.uri
}

output "internal_service_name" {
  description = "The name of the internal service"
  value       = google_cloud_run_v2_service.internal_service.name
}

output "tester_sa_email" {
  description = "The email of the tester Service Account"
  value       = google_service_account.test_sa.email
}

output "load_balancer_ip" {
  description = "The external IP address of the HTTP Load Balancer."
  value       = module.lb_http.external_ip
}
