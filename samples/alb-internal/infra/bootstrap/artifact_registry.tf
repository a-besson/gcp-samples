resource "google_artifact_registry_repository" "api" {
  repository_id = "alb-internal${var.name_suffix}"
  location      = var.region
  format        = "DOCKER"
  description   = "Container images for the alb-internal Spring Boot API"
  kms_key_name  = google_kms_crypto_key.keys["artifacts"].id
  depends_on    = [google_kms_crypto_key_iam_member.agents]
}
