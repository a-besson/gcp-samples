# infra

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 7.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 7.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | 7.46.1 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_artifact_registry_bastion"></a> [artifact\_registry\_bastion](#module\_artifact\_registry\_bastion) | GoogleCloudPlatform/artifact-registry/google | ~> 0.8 |
| <a name="module_artifact_registry_job"></a> [artifact\_registry\_job](#module\_artifact\_registry\_job) | GoogleCloudPlatform/artifact-registry/google | ~> 0.8 |
| <a name="module_artifact_registry_service"></a> [artifact\_registry\_service](#module\_artifact\_registry\_service) | GoogleCloudPlatform/artifact-registry/google | ~> 0.8 |
| <a name="module_cloud_nat"></a> [cloud\_nat](#module\_cloud\_nat) | terraform-google-modules/cloud-nat/google | ~> 7.0 |
| <a name="module_firewall_rules"></a> [firewall\_rules](#module\_firewall\_rules) | terraform-google-modules/network/google//modules/firewall-rules | ~> 18.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-google-modules/network/google | ~> 18.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [google_compute_instance.test_vm_a](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.test_vm_b](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_project_iam_member.iac_editor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.iac_iam_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.iac_secret_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.iac_storage_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.test_vm_logging](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.test_vm_monitoring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.test_vm_storage](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.artifact_registry](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.cloudresourcemanager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.compute](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.container_scanning](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_account.iac](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.test_vm_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.iac_token_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_client_openid_userinfo.operator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_openid_userinfo) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix for resource names (used in tests to avoid naming conflicts). | `string` | `"-sample"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP Project ID where the VPC will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region where subnets will be deployed. | `string` | `"europe-west9"` | no |
| <a name="input_subnet_priv_a_ip"></a> [subnet\_priv\_a\_ip](#input\_subnet\_priv\_a\_ip) | IP range for the first private subnet. | `string` | `"10.0.4.0/22"` | no |
| <a name="input_subnet_priv_a_name"></a> [subnet\_priv\_a\_name](#input\_subnet\_priv\_a\_name) | Name of the first private subnet. | `string` | `"subnet-priv-a"` | no |
| <a name="input_subnet_priv_a_secondary_ip"></a> [subnet\_priv\_a\_secondary\_ip](#input\_subnet\_priv\_a\_secondary\_ip) | Secondary IP range for the first private subnet. | `string` | `"100.64.0.0/22"` | no |
| <a name="input_subnet_priv_b_ip"></a> [subnet\_priv\_b\_ip](#input\_subnet\_priv\_b\_ip) | IP range for the second private subnet. | `string` | `"10.0.20.0/22"` | no |
| <a name="input_subnet_priv_b_name"></a> [subnet\_priv\_b\_name](#input\_subnet\_priv\_b\_name) | Name of the second private subnet. | `string` | `"subnet-priv-b"` | no |
| <a name="input_subnet_priv_b_secondary_ip"></a> [subnet\_priv\_b\_secondary\_ip](#input\_subnet\_priv\_b\_secondary\_ip) | Secondary IP range for the second private subnet. | `string` | `"100.64.4.0/22"` | no |
| <a name="input_subnet_public_ip"></a> [subnet\_public\_ip](#input\_subnet\_public\_ip) | IP range for the public subnet. | `string` | `"10.0.0.0/22"` | no |
| <a name="input_subnet_public_name"></a> [subnet\_public\_name](#input\_subnet\_public\_name) | Name of the public subnet. | `string` | `"subnet-public"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bastion_repo_name"></a> [bastion\_repo\_name](#output\_bastion\_repo\_name) | The Artifact Registry repository name for the bastion |
| <a name="output_iac_sa_email"></a> [iac\_sa\_email](#output\_iac\_sa\_email) | IaC Service Account email used for deployments. |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | The name of the VPC being created |
| <a name="output_network_self_link"></a> [network\_self\_link](#output\_network\_self\_link) | The URI of the VPC being created |
| <a name="output_subnet_priv_a"></a> [subnet\_priv\_a](#output\_subnet\_priv\_a) | private subnet A details |
| <a name="output_subnet_priv_b"></a> [subnet\_priv\_b](#output\_subnet\_priv\_b) | private subnet B details |
| <a name="output_subnet_public"></a> [subnet\_public](#output\_subnet\_public) | The public subnet details |
| <a name="output_terraform_state_bucket"></a> [terraform\_state\_bucket](#output\_terraform\_state\_bucket) | The GCS bucket name used for Terraform remote state |
<!-- END_TF_DOCS -->
