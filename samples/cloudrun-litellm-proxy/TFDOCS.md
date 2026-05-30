## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | ~> 6.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_cloudsql"></a> [cloudsql](#module\_cloudsql) | terraform-google-modules/sql-db/google//modules/postgresql | ~> 22.0 |
| <a name="module_project_services"></a> [project\_services](#module\_project\_services) | terraform-google-modules/project-factory/google//modules/project_services | ~> 18.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [google_artifact_registry_repository.litellm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_cloud_run_domain_mapping.litellm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_domain_mapping) | resource |
| [google_cloud_run_v2_service.litellm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |
| [google_cloud_run_v2_service_iam_member.invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service_iam_member) | resource |
| [google_compute_global_address.private_ip_range](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_dns_managed_zone.litellm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_record_set.litellm_cname](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_project_iam_member.runner_cloudsql_client](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.runner_log_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.runner_metric_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.runner_vertex_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_secret_manager_secret.database_url](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret.master_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_member.runner_database_url](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_iam_member.runner_master_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_version.database_url](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_service_account.litellm_runner](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_networking_connection.private_vpc_connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |
| [random_password.db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cloudsql_tier"></a> [cloudsql\_tier](#input\_cloudsql\_tier) | Cloud SQL machine tier for the Postgres instance. | `string` | `"db-f1-micro"` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | vCPU per Cloud Run instance. | `string` | `"1"` | no |
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name) | Custom domain for the Cloud Run service (e.g. llm.example.com). Leave empty to skip DNS and domain-mapping resources. | `string` | `""` | no |
| <a name="input_image_service"></a> [image\_service](#input\_image\_service) | Fully-qualified Docker image URI for the LiteLLM proxy container. | `string` | n/a | yes |
| <a name="input_max_instances"></a> [max\_instances](#input\_max\_instances) | Maximum number of Cloud Run instances. | `number` | `5` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory per Cloud Run instance. | `string` | `"1Gi"` | no |
| <a name="input_min_instances"></a> [min\_instances](#input\_min\_instances) | Minimum Cloud Run instances. 1 = warm pool, 0 = scale-to-zero (cold starts). | `number` | `1` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix appended to resource names (used for test isolation). | `string` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google Cloud Project ID hosting the LiteLLM proxy. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region used for Cloud Run, Artifact Registry, Secret Manager and Cloud SQL. | `string` | `"europe-west9"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Cloud Run service name. | `string` | `"litellm-proxy"` | no |
| <a name="input_vertex_location"></a> [vertex\_location](#input\_vertex\_location) | Vertex AI location used by LiteLLM (VERTEXAI\_LOCATION env var). | `string` | `"europe-west9"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_artifact_registry_repo"></a> [artifact\_registry\_repo](#output\_artifact\_registry\_repo) | Artifact Registry repository for the LiteLLM container image. |
| <a name="output_cloudsql_connection_name"></a> [cloudsql\_connection\_name](#output\_cloudsql\_connection\_name) | Cloud SQL connection name (PROJECT:REGION:INSTANCE) used by the Auth Proxy sidecar. |
| <a name="output_cloudsql_instance_name"></a> [cloudsql\_instance\_name](#output\_cloudsql\_instance\_name) | Cloud SQL instance name. |
| <a name="output_custom_domain"></a> [custom\_domain](#output\_custom\_domain) | Custom domain for the service (empty if var.dns\_name was not set). |
| <a name="output_database_url_secret_id"></a> [database\_url\_secret\_id](#output\_database\_url\_secret\_id) | Secret Manager secret ID holding DATABASE\_URL (populated automatically by Terraform). |
| <a name="output_dns_name_servers"></a> [dns\_name\_servers](#output\_dns\_name\_servers) | Name servers for the Cloud DNS managed zone (delegate from your registrar). |
| <a name="output_master_key_secret_id"></a> [master\_key\_secret\_id](#output\_master\_key\_secret\_id) | Secret Manager secret ID holding LITELLM\_MASTER\_KEY (seed manually via task seed-key). |
| <a name="output_runner_sa_email"></a> [runner\_sa\_email](#output\_runner\_sa\_email) | Runtime Service Account email used by the proxy and Cloud SQL Auth Proxy. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Cloud Run service name. |
| <a name="output_service_url"></a> [service\_url](#output\_service\_url) | Auto-generated Cloud Run URL (*.run.app) for the LiteLLM proxy. |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | 6.50.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_cloudsql"></a> [cloudsql](#module\_cloudsql) | terraform-google-modules/sql-db/google//modules/postgresql | ~> 22.0 |
| <a name="module_project_services"></a> [project\_services](#module\_project\_services) | terraform-google-modules/project-factory/google//modules/project_services | ~> 18.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [google_artifact_registry_repository.litellm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_bigquery_dataset.litellm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset) | resource |
| [google_bigquery_dataset_iam_member.runner_bq_editor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_member) | resource |
| [google_bigquery_table.litellm_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table) | resource |
| [google_cloud_run_domain_mapping.litellm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_domain_mapping) | resource |
| [google_cloud_run_v2_service.litellm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |
| [google_cloud_run_v2_service_iam_member.invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service_iam_member) | resource |
| [google_compute_global_address.private_ip_range](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_dns_managed_zone.litellm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_record_set.litellm_cname](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_monitoring_dashboard.litellm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_dashboard) | resource |
| [google_project_iam_member.runner_bq_job_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.runner_cloudsql_client](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.runner_cloudsql_instance_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.runner_log_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.runner_metric_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.runner_vertex_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_secret_manager_secret.database_url](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret.master_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_member.runner_database_url](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_iam_member.runner_master_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_version.database_url](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_service_account.litellm_runner](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_networking_connection.private_vpc_connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |
| [random_password.db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bigquery_dataset"></a> [bigquery\_dataset](#input\_bigquery\_dataset) | BigQuery dataset ID for LiteLLM observability logs (tokens, cost, latency). | `string` | `"litellm_observability"` | no |
| <a name="input_cloudsql_tier"></a> [cloudsql\_tier](#input\_cloudsql\_tier) | Cloud SQL machine tier for the Postgres instance. | `string` | `"db-f1-micro"` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | vCPU per Cloud Run instance. | `string` | `"1"` | no |
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name) | Custom domain for the Cloud Run service (e.g. llm.example.com). Leave empty to skip DNS and domain-mapping resources. | `string` | `""` | no |
| <a name="input_image_service"></a> [image\_service](#input\_image\_service) | Fully-qualified Docker image URI for the LiteLLM proxy container. | `string` | n/a | yes |
| <a name="input_max_instances"></a> [max\_instances](#input\_max\_instances) | Maximum number of Cloud Run instances. | `number` | `5` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory per Cloud Run instance. | `string` | `"1Gi"` | no |
| <a name="input_min_instances"></a> [min\_instances](#input\_min\_instances) | Minimum Cloud Run instances. 1 = warm pool, 0 = scale-to-zero (cold starts). | `number` | `1` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix appended to resource names (used for test isolation). | `string` | `"-sample"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google Cloud Project ID hosting the LiteLLM proxy. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region used for Cloud Run, Artifact Registry, Secret Manager and Cloud SQL. | `string` | `"europe-west9"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Cloud Run service name. | `string` | `"litellm-proxy"` | no |
| <a name="input_vertex_location"></a> [vertex\_location](#input\_vertex\_location) | Vertex AI location used by LiteLLM (VERTEXAI\_LOCATION env var). | `string` | `"europe-west9"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_artifact_registry_repo"></a> [artifact\_registry\_repo](#output\_artifact\_registry\_repo) | Artifact Registry repository for the LiteLLM container image. |
| <a name="output_bigquery_dataset"></a> [bigquery\_dataset](#output\_bigquery\_dataset) | BigQuery dataset ID holding LiteLLM observability logs. |
| <a name="output_cloudsql_connection_name"></a> [cloudsql\_connection\_name](#output\_cloudsql\_connection\_name) | Cloud SQL connection name (PROJECT:REGION:INSTANCE) used by the Auth Proxy sidecar. |
| <a name="output_cloudsql_instance_name"></a> [cloudsql\_instance\_name](#output\_cloudsql\_instance\_name) | Cloud SQL instance name. |
| <a name="output_curl_test_command"></a> [curl\_test\_command](#output\_curl\_test\_command) | A shell script/curl command to verify and test the deployed LiteLLM proxy service's liveness endpoint. |
| <a name="output_custom_domain"></a> [custom\_domain](#output\_custom\_domain) | Custom domain for the service (empty if var.dns\_name was not set). |
| <a name="output_dashboard_url"></a> [dashboard\_url](#output\_dashboard\_url) | Cloud Monitoring dashboard URL (request rate, latency, instance count). |
| <a name="output_database_url_secret_id"></a> [database\_url\_secret\_id](#output\_database\_url\_secret\_id) | Secret Manager secret ID holding DATABASE\_URL (populated automatically by Terraform). |
| <a name="output_dns_name_servers"></a> [dns\_name\_servers](#output\_dns\_name\_servers) | Name servers for the Cloud DNS managed zone (delegate from your registrar). |
| <a name="output_master_key_secret_id"></a> [master\_key\_secret\_id](#output\_master\_key\_secret\_id) | Secret Manager secret ID holding LITELLM\_MASTER\_KEY (seed manually via task seed-key). |
| <a name="output_runner_sa_email"></a> [runner\_sa\_email](#output\_runner\_sa\_email) | Runtime Service Account email used by the proxy and Cloud SQL Auth Proxy. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Cloud Run service name. |
| <a name="output_service_url"></a> [service\_url](#output\_service\_url) | Auto-generated Cloud Run URL (*.run.app) for the LiteLLM proxy. |
<!-- END_TF_DOCS -->