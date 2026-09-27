# One CMEK key per consuming service: separate revocation/rotation blast
# radius per service, instead of a single shared key.
locals {
  cmek_consumers = {
    sql       = "service-${data.google_project.this.number}@gcp-sa-cloud-sql.iam.gserviceaccount.com"
    run       = "service-${data.google_project.this.number}@serverless-robot-prod.iam.gserviceaccount.com"
    artifacts = "service-${data.google_project.this.number}@gcp-sa-artifactregistry.iam.gserviceaccount.com"
    secrets   = "service-${data.google_project.this.number}@gcp-sa-secretmanager.iam.gserviceaccount.com"
    compute   = "service-${data.google_project.this.number}@compute-system.iam.gserviceaccount.com"
  }
}

# Key ring is never destroyable in GCP: a `terraform destroy` only removes it
# from state, and the next `apply` fails with 409 AlreadyExists. Isolated in
# this create-once bootstrap stack, and protected here as a safety net.
resource "google_kms_key_ring" "main" {
  name     = "alb-internal-kr${var.name_suffix}"
  location = var.region
  project  = var.project_id

  depends_on = [time_sleep.wait_for_apis]

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "keys" {
  for_each        = local.cmek_consumers
  name            = "alb-internal-${each.key}${var.name_suffix}"
  key_ring        = google_kms_key_ring.main.id
  purpose         = "ENCRYPT_DECRYPT"
  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key_iam_member" "agents" {
  for_each      = local.cmek_consumers
  crypto_key_id = google_kms_crypto_key.keys[each.key].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${each.value}"
  depends_on    = [google_project_service_identity.agents]
}
