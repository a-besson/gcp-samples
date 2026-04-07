variables {
  project_id     = "test-project"
  region         = "europe-west1"
  domain         = "bastion.example.com"
  network        = "default"
  subnet         = "default"
  iap_user_email = "developer@example.com"
  support_email  = "admin@example.com"
  bastion_image  = "europe-west1-docker.pkg.dev/test-project/cloudrun-bastion/bastion:latest"
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

run "validate_ssl_cert_domain" {
  command = plan

  assert {
    condition     = contains(google_compute_managed_ssl_certificate.bastion_ssl.managed[0].domains, "bastion.example.com")
    error_message = "SSL certificate must include the configured domain."
  }
}

run "validate_service_account" {
  command = plan

  assert {
    condition     = google_service_account.bastion_sa.account_id == "cloudrun-bastion-sa"
    error_message = "Service account ID must be cloudrun-bastion-sa."
  }
}

run "validate_iap_access_binding" {
  command = plan

  assert {
    condition     = google_iap_web_backend_service_iam_member.bastion_iap_user.role == "roles/iap.httpsResourceAccessor"
    error_message = "IAP IAM member must have the httpsResourceAccessor role."
  }
}

run "validate_sql_private_ip" {
  command = plan

  assert {
    condition     = google_sql_database_instance.postgres.settings[0].ip_configuration[0].ipv4_enabled == false
    error_message = "SQL database must have no public IP (ipv4_enabled = false)."
  }
}
