resource "google_artifact_registry_repository" "litellm" {
  location      = var.region
  repository_id = "litellm-proxy${var.name_suffix}"
  description   = "Container images for the LiteLLM proxy on Cloud Run."
  format        = "DOCKER"
  project       = var.project_id
}
