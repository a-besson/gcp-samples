output "service_url" {
  description = "Auto-generated Cloud Run URL (*.run.app) for the LiteLLM proxy."
  value       = google_cloud_run_v2_service.litellm.uri
}

output "service_name" {
  description = "Cloud Run service name."
  value       = google_cloud_run_v2_service.litellm.name
}

output "custom_domain" {
  description = "Custom domain for the service (empty if var.dns_name was not set)."
  value       = var.dns_name != "" ? "https://${var.dns_name}" : ""
}

output "runner_sa_email" {
  description = "Runtime Service Account email used by the proxy and Cloud SQL Auth Proxy."
  value       = google_service_account.litellm_runner.email
}


output "master_key_secret_id" {
  description = "Secret Manager secret ID holding LITELLM_MASTER_KEY (seed manually via task seed-key)."
  value       = google_secret_manager_secret.master_key.secret_id
}

output "database_url_secret_id" {
  description = "Secret Manager secret ID holding DATABASE_URL (populated automatically by Terraform)."
  value       = google_secret_manager_secret.database_url.secret_id
}

output "cloudsql_instance_name" {
  description = "Cloud SQL instance name."
  value       = module.cloudsql.instance_name
}

output "cloudsql_connection_name" {
  description = "Cloud SQL connection name (PROJECT:REGION:INSTANCE) used by the Auth Proxy sidecar."
  value       = module.cloudsql.instance_connection_name
}

output "artifact_registry_repo" {
  description = "Artifact Registry repository for the LiteLLM container image."
  value       = google_artifact_registry_repository.litellm.repository_id
}

output "dns_name_servers" {
  description = "Name servers for the Cloud DNS managed zone (delegate from your registrar)."
  value       = var.dns_name != "" ? google_dns_managed_zone.litellm[0].name_servers : []
}

output "bigquery_dataset" {
  description = "BigQuery dataset ID holding LiteLLM observability logs."
  value       = google_bigquery_dataset.litellm.dataset_id
}

output "dashboard_url" {
  description = "Cloud Monitoring dashboard URL (request rate, latency, instance count)."
  value       = "https://console.cloud.google.com/monitoring/dashboards/custom/${split("/", google_monitoring_dashboard.litellm.id)[3]}?project=${var.project_id}"
}

output "curl_test_command" {
  description = "A shell script/curl command to verify and test the deployed LiteLLM proxy service's liveness endpoint."
  value       = <<EOT
curl -sS -f "${google_cloud_run_v2_service.litellm.uri}/health/liveliness"
EOT
}

output "user_keys" {
  description = "Virtual API keys generated for each user defined in users.yaml (sensitive)."
  value = {
    for name, key in litellm_key.user : name => {
      key_alias = key.key_alias
      key       = key.key
    }
  }
  sensitive = true
}

output "curl_user_test_commands" {
  description = "Shell commands to test each user's virtual key against the LiteLLM proxy."
  value = join("\n\n", [
    for name, key in litellm_key.user :
    <<-EOT
    # Test user: ${name}
    curl -sS -X POST "${google_cloud_run_v2_service.litellm.uri}/v1/chat/completions" \
      -H "x-api-key: Bearer $(terraform output -json user_keys | jq -r '.${name}.key')" \
      -H "Content-Type: application/json" \
      -d '{"model":"gemini-2.5-flash","messages":[{"role":"user","content":"Reply OK"}]}' | jq .
    EOT
  ])
}
