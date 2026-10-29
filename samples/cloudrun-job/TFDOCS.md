# infra

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 7.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | 7.46.2 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_artifact_registry"></a> [artifact\_registry](#module\_artifact\_registry) | GoogleCloudPlatform/artifact-registry/google | ~> 0.8 |
| <a name="module_project_services"></a> [project\_services](#module\_project\_services) | terraform-google-modules/project-factory/google//modules/project_services | ~> 18.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [google_cloud_run_v2_job.hello_job](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_job) | resource |
| [google_project_iam_member.cloudrun_sa_ar_reader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.cloudrun_sa_log_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.cloudrun_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_image_job"></a> [image\_job](#input\_image\_job) | Docker image for the Cloud Run Job | `string` | n/a | yes |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix for the resource names (e.g. -dev or -test). | `string` | `"-sample"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google Cloud Project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region to deploy resources in | `string` | `"europe-west1"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_artifact_registry_url"></a> [artifact\_registry\_url](#output\_artifact\_registry\_url) | The Artifact Registry repository URL |
| <a name="output_job_name"></a> [job\_name](#output\_job\_name) | The name of the Cloud Run Job |
| <a name="output_run_job_command"></a> [run\_job\_command](#output\_run\_job\_command) | gcloud command to manually trigger the Cloud Run Job |
<!-- END_TF_DOCS -->
