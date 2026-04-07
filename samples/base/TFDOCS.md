# infra

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.45.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_artifact_registry_job"></a> [artifact\_registry\_job](#module\_artifact\_registry\_job) | GoogleCloudPlatform/artifact-registry/google | ~> 0.8 |
| <a name="module_artifact_registry_service"></a> [artifact\_registry\_service](#module\_artifact\_registry\_service) | GoogleCloudPlatform/artifact-registry/google | ~> 0.8 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-google-modules/network/google | ~> 9.0 |

## Resources

| Name | Type |
|------|------|
| [google_project_service.container_scanning](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP Project ID where the VPC will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region where subnets will be deployed. | `string` | `"europe-west9"` | no |
| <a name="input_subnet_priv_a_ip"></a> [subnet\_priv\_a\_ip](#input\_subnet\_priv\_a\_ip) | IP range for the first private subnet. | `string` | `"10.0.4.0/20"` | no |
| <a name="input_subnet_priv_a_name"></a> [subnet\_priv\_a\_name](#input\_subnet\_priv\_a\_name) | Name of the first private subnet. | `string` | `"subnet-priv-a"` | no |
| <a name="input_subnet_priv_b_ip"></a> [subnet\_priv\_b\_ip](#input\_subnet\_priv\_b\_ip) | IP range for the second private subnet. | `string` | `"10.0.20.0/20"` | no |
| <a name="input_subnet_priv_b_name"></a> [subnet\_priv\_b\_name](#input\_subnet\_priv\_b\_name) | Name of the second private subnet. | `string` | `"subnet-priv-b"` | no |
| <a name="input_subnet_public_ip"></a> [subnet\_public\_ip](#input\_subnet\_public\_ip) | IP range for the public subnet. | `string` | `"10.0.0.0/22"` | no |
| <a name="input_subnet_public_name"></a> [subnet\_public\_name](#input\_subnet\_public\_name) | Name of the public subnet. | `string` | `"subnet-public"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | The name of the VPC being created |
| <a name="output_network_self_link"></a> [network\_self\_link](#output\_network\_self\_link) | The URI of the VPC being created |
| <a name="output_subnet_priv_a"></a> [subnet\_priv\_a](#output\_subnet\_priv\_a) | private subnet A details |
| <a name="output_subnet_priv_b"></a> [subnet\_priv\_b](#output\_subnet\_priv\_b) | private subnet B details |
| <a name="output_subnet_public"></a> [subnet\_public](#output\_subnet\_public) | The public subnet details |
<!-- END_TF_DOCS -->
