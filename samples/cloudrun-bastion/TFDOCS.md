# infra

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.11 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | 6.50.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_lb_http"></a> [lb\_http](#module\_lb\_http) | terraform-google-modules/lb-http/google//modules/serverless_negs | ~> 12.0 |
| <a name="module_project_services"></a> [project\_services](#module\_project\_services) | terraform-google-modules/project-factory/google//modules/project_services | ~> 18.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [google_cloud_run_v2_service.bastion](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |
| [google_cloud_run_v2_service_iam_member.bastion_invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service_iam_member) | resource |
| [google_compute_global_address.private_ip_alloc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_endpoints_service.bastion_dns](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/endpoints_service) | resource |
| [google_iap_client.bastion_iap_client](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_client) | resource |
| [google_iap_web_backend_service_iam_member.bastion_iap_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_web_backend_service_iam_member) | resource |
| [google_service_account.bastion_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_networking_connection.private_vpc_connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |
| [google_sql_database.database](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_database_instance.postgres](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_user.users](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [random_id.db_name_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_iap_user_email"></a> [iap\_user\_email](#input\_iap\_user\_email) | Email of the user or group granted IAP-secured Web App User access (e.g., user@example.com). | `string` | n/a | yes |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix for the resource names (e.g. -dev or -test). | `string` | `"-sample"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google Cloud Project ID. | `string` | n/a | yes |
| <a name="input_project_number"></a> [project\_number](#input\_project\_number) | The Google Cloud Project Number (numeric ID). | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region to deploy the Cloud Run service. | `string` | `"europe-west1"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bastion_url"></a> [bastion\_url](#output\_bastion\_url) | The HTTPS URL for the Cloud Run Bastion (secured by IAP). |
| <a name="output_cloud_run_uri"></a> [cloud\_run\_uri](#output\_cloud\_run\_uri) | The auto-generated Cloud Run URI (internal use only). |
| <a name="output_db_instance_connection_name"></a> [db\_instance\_connection\_name](#output\_db\_instance\_connection\_name) | The connection name of the Cloud SQL instance for use with Cloud SQL Auth Proxy. |
| <a name="output_db_instance_ip"></a> [db\_instance\_ip](#output\_db\_instance\_ip) | The private IP address of the Cloud SQL instance. |
| <a name="output_db_password"></a> [db\_password](#output\_db\_password) | The auto-generated password for the test user. |
| <a name="output_load_balancer_ip"></a> [load\_balancer\_ip](#output\_load\_balancer\_ip) | The external IP address of the Global Load Balancer. |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | The email of the Cloud Run Bastion Service Account. |
<!-- END_TF_DOCS -->
