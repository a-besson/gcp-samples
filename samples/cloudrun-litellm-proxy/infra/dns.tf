resource "google_dns_managed_zone" "litellm" {
  count    = local.create_dns
  name     = "litellm-zone${var.name_suffix}"
  dns_name = local.zone_dns
  project  = var.project_id

  description = "Managed zone for the LiteLLM proxy custom domain."

  depends_on = [module.project_services]
}

# Cloud Run domain mapping requires a CNAME to ghs.googlehosted.com.
# TLS is managed automatically by Cloud Run once the mapping is verified.
resource "google_dns_record_set" "litellm_cname" {
  count        = local.create_dns
  name         = local.record_fqdn
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.litellm[0].name
  rrdatas      = ["ghs.googlehosted.com."]
  project      = var.project_id
}
