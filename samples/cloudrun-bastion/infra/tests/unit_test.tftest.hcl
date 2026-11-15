variables {
  project_id     = "test-project"
  region         = "europe-west1"
  iap_user_email = "developer@example.com"
}

run "validate_cloud_run_ingress" {
  command = plan

  assert {
    condition     = google_cloud_run_v2_service.bastion.ingress == "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
    error_message = "Cloud Run ingress must be INTERNAL_LOAD_BALANCER for IAP to be the sole entry point."
  }
}

run "validate_vpc_egress" {
  command = plan

  assert {
    condition     = google_cloud_run_v2_service.bastion.template[0].vpc_access[0].egress == "ALL_TRAFFIC"
    error_message = "All egress traffic must route through Direct VPC Egress."
  }
}

# The managed certificate lives inside module.lb_http (not addressable from a
# test): check the Cloud Endpoints domain it is issued for instead.
run "validate_managed_domain" {
  command = plan

  assert {
    condition     = google_endpoints_service.bastion_dns.service_name == "bastion${var.name_suffix}.endpoints.${var.project_id}.cloud.goog"
    error_message = "The Cloud Endpoints domain (used by the managed SSL certificate) must follow bastion<name_suffix>.endpoints.<project>.cloud.goog."
  }

  assert {
    condition     = output.bastion_url == "https://${google_endpoints_service.bastion_dns.service_name}"
    error_message = "bastion_url must point at the Cloud Endpoints domain served by the managed certificate."
  }
}

run "validate_service_account" {
  command = plan

  assert {
    condition     = google_service_account.bastion_sa.account_id == "cloudrun-bastion-sa${var.name_suffix}"
    error_message = "Service account ID must be cloudrun-bastion-sa<name_suffix>."
  }
}

run "validate_iap_access_binding" {
  command = plan

  assert {
    condition     = google_iap_web_backend_service_iam_member.bastion_iap_user[0].role == "roles/iap.httpsResourceAccessor"
    error_message = "IAP IAM member must have the httpsResourceAccessor role."
  }
}

# The public IPv4 is a documented, accepted exception (README "No Public
# Ingress", .trivyignore.yaml GCP-0017): assert the invariants that exception
# relies on instead of the opposite of the code.
run "validate_sql_access_is_proxy_only" {
  command = plan

  assert {
    condition     = length(google_sql_database_instance.postgres.settings[0].ip_configuration[0].authorized_networks) == 0
    error_message = "No authorized network may be set: the public IP must only be reachable through the IAM-authenticated Cloud SQL Auth Proxy."
  }

  assert {
    condition     = google_sql_database_instance.postgres.settings[0].ip_configuration[0].ssl_mode == "ENCRYPTED_ONLY"
    error_message = "Cloud SQL must only accept encrypted connections (ssl_mode = ENCRYPTED_ONLY)."
  }
}
