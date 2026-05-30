<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_gke"></a> [gke](#module\_gke) | terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster | ~> 36.0 |
| <a name="module_project_services"></a> [project\_services](#module\_project\_services) | terraform-google-modules/project-factory/google//modules/project_services | ~> 18.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the GKE Autopilot cluster | `string` | `"gke-autopilot"` | no |
| <a name="input_master_authorized_networks"></a> [master\_authorized\_networks](#input\_master\_authorized\_networks) | External networks authorized to access the GKE master endpoint | <pre>list(object({<br/>    cidr_block   = string<br/>    display_name = string<br/>  }))</pre> | `[]` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix for resource naming (used for test isolation) | `string` | `"-sample"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google Cloud Project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region to deploy GKE resources in | `string` | `"europe-west9"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | The public certificate of the cluster (base64 encoded) |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | The IP address of the cluster master (private) |
| <a name="output_cluster_location"></a> [cluster\_location](#output\_cluster\_location) | The region of the cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the GKE cluster |
| <a name="output_kubectl_connect"></a> [kubectl\_connect](#output\_kubectl\_connect) | Shell script to configure kubectl and deploy nginx |
| <a name="output_master_authorized_networks_config"></a> [master\_authorized\_networks\_config](#output\_master\_authorized\_networks\_config) | The master authorized networks configuration |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | The email of the GKE node service account |
<!-- END_TF_DOCS -->