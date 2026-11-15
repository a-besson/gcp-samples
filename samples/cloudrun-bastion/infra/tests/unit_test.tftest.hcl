# 100% offline unit tests: mock_provider replaces every google/google-beta
# API call, so this file runs in CI with zero GCP credentials
# (`task test` = `terraform init -backend=false` + `terraform test`).

mock_provider "google" {}
mock_provider "google-beta" {}

# Outputs read from the base stack (GCS remote state) in a real plan.
override_data {
  target = data.terraform_remote_state.base
  values = {
    outputs = {
      network_name      = "gcp-sample-base-vpc-test"
      network_self_link = "projects/test-project/global/networks/gcp-sample-base-vpc-test"
      bastion_repo_name = "cloudrun-bastion-test"
      subnet_public     = { id = "projects/test-project/regions/europe-west1/subnetworks/subnet-public-test", name = "subnet-public-test", ip_cidr_range = "10.0.0.0/22" }
      subnet_priv_a     = { id = "projects/test-project/regions/europe-west1/subnetworks/subnet-priv-a-test", name = "subnet-priv-a-test", ip_cidr_range = "10.0.4.0/22" }
    }
  }
}

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

# Only the IAP service agent may invoke the service: the INTERNAL_LOAD_BALANCER
# ingress also admits VPC traffic, which must not bypass IAP.
run "validate_invoker_is_iap_only" {
  command = plan

  assert {
    condition     = google_cloud_run_v2_service_iam_member.bastion_invoker.member == "serviceAccount:service-${data.google_project.this.number}@gcp-sa-iap.iam.gserviceaccount.com"
    error_message = "roles/run.invoker must be granted to the IAP service agent only (never allUsers)."
  }
}

# Defense in depth on top of the private-only IP (validate_sql_private_ip).
run "validate_sql_access_is_proxy_only" {
  command = plan

  assert {
    condition     = length(google_sql_database_instance.postgres.settings[0].ip_configuration[0].authorized_networks) == 0
    error_message = "No authorized network may be set on the Cloud SQL instance."
  }

  assert {
    condition     = google_sql_database_instance.postgres.settings[0].ip_configuration[0].ssl_mode == "ENCRYPTED_ONLY"
    error_message = "Cloud SQL must only accept encrypted connections (ssl_mode = ENCRYPTED_ONLY)."
  }
}

run "validate_sql_private_ip" {
  command = plan

  assert {
    condition     = google_sql_database_instance.postgres.database_version == "POSTGRES_17" && google_sql_database_instance.postgres.settings[0].edition == "ENTERPRISE"
    error_message = "The test database must run PostgreSQL 17 on the Enterprise edition (shared-core tier)."
  }

  assert {
    condition     = google_sql_database_instance.postgres.settings[0].ip_configuration[0].ipv4_enabled == false
    error_message = "SQL database must have no public IP (ipv4_enabled = false)."
  }
}
