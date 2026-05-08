output "instance_name" {
  description = "Name of the deployed GCE instance"
  value       = google_compute_instance.llm_node.name
}

output "instance_private_ip" {
  description = "Private IP address of the GCE instance"
  value       = google_compute_instance.llm_node.network_interface[0].network_ip
}

output "iap_ssh_command" {
  description = "Connect to the instance via IAP SSH tunnel"
  value       = "gcloud compute ssh ${google_compute_instance.llm_node.name} --project ${var.project_id} --zone ${var.zone} --tunnel-through-iap"
}

output "iap_tunnel_command" {
  description = "Create a secure tunnel to access the LLM API locally without a public IP"
  value       = "gcloud compute start-iap-tunnel ${google_compute_instance.llm_node.name} 11434 --project ${var.project_id} --zone ${var.zone} --local-host-port=localhost:11434"
}

output "api_instructions" {
  description = "Instructions to call the Ollama API once the IAP tunnel is active"
  value       = "Once the tunnel is active, call the API at http://localhost:11434 (Authenticated via your gcloud account)"
}
