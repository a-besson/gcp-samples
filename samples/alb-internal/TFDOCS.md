# infra

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | 6.50.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | 6.50.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.1 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.4.1 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_project_services"></a> [project\_services](#module\_project\_services) | terraform-google-modules/project-factory/google//modules/project_services | ~> 18.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [google-beta_google_compute_region_backend_service.api](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_region_backend_service) | resource |
| [google-beta_google_project_service_identity.iap](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_project_service_identity) | resource |
| [google_cloud_run_v2_service.api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |
| [google_cloud_run_v2_service_iam_member.iap_invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service_iam_member) | resource |
| [google_compute_address.sql_psc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.allow_client_to_ilb](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_iap_ssh](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_run_to_sql](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.deny_all_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.deny_all_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_forwarding_rule.api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_forwarding_rule.sql_psc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_instance.client](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_network.vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_region_network_endpoint_group.api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_endpoint_group) | resource |
| [google_compute_region_security_policy.api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_security_policy) | resource |
| [google_compute_region_security_policy_rule.deny_default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_security_policy_rule) | resource |
| [google_compute_region_security_policy_rule.rate_limit](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_security_policy_rule) | resource |
| [google_compute_region_security_policy_rule.waf](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_security_policy_rule) | resource |
| [google_compute_region_ssl_certificate.api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_ssl_certificate) | resource |
| [google_compute_region_target_https_proxy.api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_target_https_proxy) | resource |
| [google_compute_region_url_map.api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_url_map) | resource |
| [google_compute_subnetwork.application](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.isolated](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.proxy_only](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_dns_managed_zone.api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_managed_zone.sql](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_record_set.api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.sql](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_iap_web_region_backend_service_iam_member.client_vm_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_web_region_backend_service_iam_member) | resource |
| [google_iap_web_region_backend_service_iam_member.user_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_web_region_backend_service_iam_member) | resource |
| [google_logging_metric.armor_denied](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_metric) | resource |
| [google_logging_metric.armor_preview_matched](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_metric) | resource |
| [google_monitoring_alert_policy.armor_denied](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_project_iam_member.api_cloudsql_client](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.api_log_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.api_metric_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.iap_tunnel_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_secret_manager_secret.db_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_member.api_secret_accessor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_version.db_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_service_account.api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.client_vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.operator_token_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_sql_database.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_database_instance.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_user.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [random_id.db](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.db](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.api](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.api](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [google_artifact_registry_docker_image.api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/artifact_registry_docker_image) | data source |
| [google_project.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [terraform_remote_state.bootstrap](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alert_notification_channels"></a> [alert\_notification\_channels](#input\_alert\_notification\_channels) | Monitoring notification channel IDs notified when Cloud Armor blocks an abnormal volume of traffic (format: projects/<project>/notificationChannels/<id>). Empty by default: the alert policy is still created and visible in the console, but sends no notification. | `list(string)` | `[]` | no |
| <a name="input_db_tier"></a> [db\_tier](#input\_db\_tier) | Cloud SQL machine tier. db-f1-micro is the lowest-cost shared-core tier, suitable for a demo workload. | `string` | `"db-f1-micro"` | no |
| <a name="input_iap_user_email"></a> [iap\_user\_email](#input\_iap\_user\_email) | Email of the user or group granted IAP access to the API and SSH tunnel access to the client VM (e.g., user@example.com). | `string` | n/a | yes |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix for resource names (e.g. -dev or -test). | `string` | `"-sample"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google Cloud Project ID. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region for every resource in this sample. Overrides the root .env REGION (europe-west9): this sample is pinned to Belgium. | `string` | `"europe-west1"` | no |
| <a name="input_vpc_cidr_application"></a> [vpc\_cidr\_application](#input\_vpc\_cidr\_application) | CIDR range for subnet-isolated-application (Cloud Run Direct VPC Egress NIC + Cloud SQL PSC endpoint). | `string` | `"10.20.1.0/24"` | no |
| <a name="input_vpc_cidr_isolated"></a> [vpc\_cidr\_isolated](#input\_vpc\_cidr\_isolated) | CIDR range for subnet-isolated (client VM + ILB forwarding rule VIP). | `string` | `"10.20.0.0/24"` | no |
| <a name="input_vpc_cidr_proxy_only"></a> [vpc\_cidr\_proxy\_only](#input\_vpc\_cidr\_proxy\_only) | CIDR range for the mandatory REGIONAL\_MANAGED\_PROXY subnet used by the regional internal Application Load Balancer. | `string` | `"10.20.2.0/24"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_api_host"></a> [api\_host](#output\_api\_host) | The internal DNS hostname of the API (used by the e2e tests to build the Host header / URL). |
| <a name="output_api_url"></a> [api\_url](#output\_api\_url) | The internal HTTPS URL of the API, reachable only from inside the VPC (or via the client VM). |
| <a name="output_client_vm_name"></a> [client\_vm\_name](#output\_client\_vm\_name) | The name of the client VM, for `gcloud compute ssh`. |
| <a name="output_client_vm_zone"></a> [client\_vm\_zone](#output\_client\_vm\_zone) | The zone of the client VM, for `gcloud compute ssh`. |
| <a name="output_cloud_run_service_name"></a> [cloud\_run\_service\_name](#output\_cloud\_run\_service\_name) | The name of the Cloud Run API service. |
| <a name="output_cloud_sql_connection_name"></a> [cloud\_sql\_connection\_name](#output\_cloud\_sql\_connection\_name) | The Cloud SQL instance connection name, for use with the Cloud SQL Auth Proxy. |
| <a name="output_forwarding_rule_ip"></a> [forwarding\_rule\_ip](#output\_forwarding\_rule\_ip) | The internal VIP address of the ALB forwarding rule. |
| <a name="output_vpc_network_name"></a> [vpc\_network\_name](#output\_vpc\_network\_name) | The name of the VPC network. |
<!-- END_TF_DOCS -->
