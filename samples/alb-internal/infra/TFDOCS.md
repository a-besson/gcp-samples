# bootstrap

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 6.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.13 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | 6.50.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | 6.50.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.14.2 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_project_services"></a> [project\_services](#module\_project\_services) | terraform-google-modules/project-factory/google//modules/project_services | ~> 18.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [google-beta_google_project_service_identity.agents](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_project_service_identity) | resource |
| [google_artifact_registry_repository.api](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_kms_crypto_key.keys](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key_iam_member.agents](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_kms_key_ring.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring) | resource |
| [time_sleep.wait_for_apis](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [google_project.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix for resource names (e.g. -dev or -test). Changing it creates a fresh KMS key ring, since key rings can never be deleted from GCP. | `string` | `"-sample"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google Cloud Project ID. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region for the KMS key ring and the Artifact Registry repository. Must match the region used by infra/ (Cloud SQL, Cloud Run). | `string` | `"europe-west1"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_artifact_repository_name"></a> [artifact\_repository\_name](#output\_artifact\_repository\_name) | Artifact Registry repository name (used to build the image URL). |
| <a name="output_artifact_repository_url"></a> [artifact\_repository\_url](#output\_artifact\_repository\_url) | Full Artifact Registry repository URL. |
| <a name="output_kms_key_compute"></a> [kms\_key\_compute](#output\_kms\_key\_compute) | CMEK key ID for the client VM boot disk. |
| <a name="output_kms_key_ring_id"></a> [kms\_key\_ring\_id](#output\_kms\_key\_ring\_id) | The KMS key ring ID, for reference/debugging. |
| <a name="output_kms_key_run"></a> [kms\_key\_run](#output\_kms\_key\_run) | CMEK key ID for the Cloud Run service. |
| <a name="output_kms_key_secrets"></a> [kms\_key\_secrets](#output\_kms\_key\_secrets) | CMEK key ID for Secret Manager secret replication. |
| <a name="output_kms_key_sql"></a> [kms\_key\_sql](#output\_kms\_key\_sql) | CMEK key ID for Cloud SQL disk/backup encryption. |
<!-- END_TF_DOCS -->
