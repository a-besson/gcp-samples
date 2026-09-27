# 100% offline unit tests: mock_provider replaces every google/google-beta
# API call, so this file runs in CI with zero GCP credentials
# (`task test` = `terraform init -backend=false` + `terraform test`).

mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id     = "test-project"
  region         = "europe-west1"
  name_suffix    = "-test"
  iap_user_email = "developer@example.com"
}

override_data {
  target = data.terraform_remote_state.bootstrap
  values = {
    outputs = {
      kms_key_sql              = "projects/test-project/locations/europe-west1/keyRings/alb-internal-kr-test/cryptoKeys/alb-internal-sql-test"
      kms_key_run              = "projects/test-project/locations/europe-west1/keyRings/alb-internal-kr-test/cryptoKeys/alb-internal-run-test"
      kms_key_secrets          = "projects/test-project/locations/europe-west1/keyRings/alb-internal-kr-test/cryptoKeys/alb-internal-secrets-test"
      kms_key_compute          = "projects/test-project/locations/europe-west1/keyRings/alb-internal-kr-test/cryptoKeys/alb-internal-compute-test"
      kms_key_ring_id          = "projects/test-project/locations/europe-west1/keyRings/alb-internal-kr-test"
      artifact_repository_name = "alb-internal-test"
      artifact_repository_url  = "europe-west1-docker.pkg.dev/test-project/alb-internal-test"
    }
  }
}

run "cloud_run_ingress_is_ilb_only" {
  command = plan

  assert {
    condition     = google_cloud_run_v2_service.api.ingress == "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
    error_message = "Cloud Run ingress must be INTERNAL_LOAD_BALANCER: the ILB/IAP must be the sole entry point."
  }

  assert {
    condition     = google_cloud_run_v2_service.api.template[0].vpc_access[0].network_interfaces[0].tags[0] == "alb-internal-api"
    error_message = "Cloud Run must carry the alb-internal-api network tag, the only firewall selector Direct VPC Egress supports."
  }

  assert {
    condition     = google_cloud_run_v2_service.api.template[0].encryption_key != ""
    error_message = "Cloud Run must be encrypted with the CMEK key from the bootstrap stack."
  }
}

run "cloud_sql_has_no_public_ip_and_uses_psc" {
  command = plan

  assert {
    condition     = google_sql_database_instance.app.settings[0].ip_configuration[0].ipv4_enabled == false
    error_message = "Cloud SQL must have no public IP (ipv4_enabled = false)."
  }

  assert {
    # psc_config is a set block: not directly indexable, hence the `for`.
    condition     = anytrue([for c in google_sql_database_instance.app.settings[0].ip_configuration[0].psc_config : c.psc_enabled])
    error_message = "Cloud SQL must expose a Private Service Connect endpoint."
  }

  assert {
    condition     = google_sql_database_instance.app.encryption_key_name != ""
    error_message = "Cloud SQL must be encrypted with a CMEK key."
  }
}

run "alb_is_internal_managed" {
  command = plan

  assert {
    condition     = google_compute_forwarding_rule.api.load_balancing_scheme == "INTERNAL_MANAGED"
    error_message = "The forwarding rule must use the INTERNAL_MANAGED scheme (regional internal ALB)."
  }

  assert {
    condition     = google_compute_subnetwork.proxy_only.purpose == "REGIONAL_MANAGED_PROXY"
    error_message = "subnet-proxy-only must carry the REGIONAL_MANAGED_PROXY purpose required by the regional internal ALB."
  }
}

run "iap_and_cloud_armor_are_enabled" {
  command = plan

  assert {
    condition     = google_compute_region_backend_service.api.iap[0].enabled == true
    error_message = "IAP must be enabled on the backend service."
  }

  assert {
    # Checking the policy resource itself, not backend_service.security_policy:
    # that field chains through a mocked resource .id that stays unknown at
    # plan time under `command = plan`.
    condition     = google_compute_region_security_policy.api.type == "CLOUD_ARMOR"
    error_message = "A regional Cloud Armor (type = CLOUD_ARMOR) security policy must exist."
  }

  assert {
    condition     = google_compute_region_security_policy_rule.deny_default.priority == 2000
    error_message = "The default-deny Cloud Armor rule must exist at priority 2000 (never 2147483647, already used by the policy's auto-created allow rule)."
  }

  assert {
    condition     = google_compute_region_security_policy.api.advanced_options_config[0].json_parsing == "STANDARD"
    error_message = "JSON parsing must be STANDARD: the API only speaks JSON, and the default (DISABLED) evaluates request bodies as a flat string, causing both false positives and JSON-encoded SQLi bypasses."
  }
}

# The load-bearing invariant of armor.tf: Cloud Armor stops at the first
# matching rule, and the priority-900 rule is what ALLOWS legitimate
# subnet-isolated traffic. Any WAF rule declared at a priority above 900 would
# never be reached - it would be dead code that silently provides no
# protection at all.
run "waf_rules_are_evaluated_before_the_allow_rule" {
  command = plan

  assert {
    condition = alltrue([
      for r in google_compute_region_security_policy_rule.waf :
      r.priority < google_compute_region_security_policy_rule.rate_limit.priority
    ])
    error_message = "Every WAF rule must have a priority below the rate-limit/allow rule (900), otherwise it is never evaluated."
  }

  assert {
    condition     = google_compute_region_security_policy_rule.rate_limit.priority < google_compute_region_security_policy_rule.deny_default.priority
    error_message = "The rate-limit/allow rule must be evaluated before the default-deny rule."
  }
}

run "waf_rulesets_are_current_and_explicitly_tuned" {
  command = plan

  assert {
    condition = alltrue([
      for r in google_compute_region_security_policy_rule.waf :
      can(regex("evaluatePreconfiguredWaf\\(", r.match[0].expr[0].expression))
    ])
    error_message = "WAF rules must use evaluatePreconfiguredWaf(): evaluatePreconfiguredExpr() inherits the implicit default sensitivity 4 (OWASP paranoia level 4), which is far too noisy."
  }

  assert {
    condition = alltrue([
      for r in google_compute_region_security_policy_rule.waf :
      can(regex("'sensitivity': 1", r.match[0].expr[0].expression))
    ])
    error_message = "Every WAF ruleset must pin sensitivity explicitly to 1 (Google's documented starting point), never inherit the default."
  }

  # CRS 3.3 does not ship the `java` ruleset at all - the most relevant one for
  # a Spring Boot / Java application.
  assert {
    condition     = can(regex("java-v422-stable", google_compute_region_security_policy_rule.waf["java"].match[0].expr[0].expression))
    error_message = "The Java attack ruleset (CRS 4.22) must be enabled: this is a Spring Boot / Java 25 application, and CRS 3.3 does not include it."
  }

  assert {
    condition     = google_compute_region_security_policy_rule.waf["scannerdetection"].preview == true
    error_message = "scannerdetection must stay in preview: its only signature matches scanner user-agents, and the curl-based e2e tests could trip it. Observe via the armor-preview-matched metric before enforcing."
  }
}

run "rate_limiting_bans_repeat_offenders" {
  command = plan

  assert {
    condition     = google_compute_region_security_policy_rule.rate_limit.action == "rate_based_ban"
    error_message = "The rate-limit rule must use rate_based_ban, not throttle: a plain throttle lets an attacker probe indefinitely at exactly the threshold rate."
  }

  assert {
    condition     = google_compute_region_security_policy_rule.rate_limit.rate_limit_options[0].conform_action == "allow"
    error_message = "The rate-limit rule doubles as the allow rule for subnet-isolated: conform_action must stay allow, or all legitimate traffic falls through to the default deny."
  }

  assert {
    condition     = google_compute_region_security_policy_rule.rate_limit.rate_limit_options[0].ban_duration_sec > 0
    error_message = "rate_based_ban requires a non-zero ban_duration_sec."
  }
}

run "cloud_armor_denials_are_detected" {
  command = plan

  assert {
    condition     = can(regex("enforcedSecurityPolicy.outcome", google_logging_metric.armor_denied.filter))
    error_message = "A log-based metric must count enforced Cloud Armor denials: request logging is already enabled and paid for, detection is the missing half."
  }

  assert {
    condition     = can(regex("previewSecurityPolicy.outcome", google_logging_metric.armor_preview_matched.filter))
    error_message = "Preview-mode rules log under previewSecurityPolicy, not enforcedSecurityPolicy: without this metric the preview rule is unobservable and therefore useless."
  }

  assert {
    condition     = length(google_monitoring_alert_policy.armor_denied.conditions) > 0
    error_message = "An alert policy must watch the Cloud Armor denial metric."
  }
}

run "firewall_denies_by_default" {
  command = plan

  assert {
    condition     = google_compute_firewall.deny_all_ingress.priority == 65533
    error_message = "deny-all-ingress must exist at priority 65533."
  }

  assert {
    condition     = google_compute_firewall.deny_all_egress.priority == 65533
    error_message = "deny-all-egress must exist at priority 65533."
  }
}

run "api_service_account_is_least_privilege" {
  command = plan

  assert {
    condition = alltrue([
      for r in [
        google_project_iam_member.api_cloudsql_client.role,
        google_project_iam_member.api_log_writer.role,
        google_project_iam_member.api_metric_writer.role,
      ] : !contains(["roles/editor", "roles/owner"], r)
    ])
    error_message = "The Cloud Run runtime service account must never hold roles/editor or roles/owner."
  }

  assert {
    condition     = google_secret_manager_secret_iam_member.api_secret_accessor.role == "roles/secretmanager.secretAccessor"
    error_message = "Secret access must be scoped to roles/secretmanager.secretAccessor on the single secret, not a project-level role."
  }
}
