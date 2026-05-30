resource "google_cloud_run_domain_mapping" "litellm" {
  count    = local.create_dns
  location = var.region
  name     = var.dns_name
  project  = var.project_id

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.litellm.name
  }

  depends_on = [google_dns_managed_zone.litellm]
}
