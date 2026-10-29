# Terraform Documentation - ai-llm-perso

## Description
Ce projet déploie une instance GCE (G2 + NVIDIA L4) sécurisée pour l'hébergement du LLM Gemma 4 via Ollama.

## Resources

| Name | Type |
|------|------|
| [google_compute_instance.llm_node](vm.tf) | Resource |
| [google_compute_resource_policy.llm_schedule](scheduler.tf) | Resource |
| [google_compute_firewall.allow_iap](vpc.tf) | Resource |
| [module.vpc](vpc.tf) | Module |
| [module.cloud_nat](vpc.tf) | Module |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | GCP Project ID | `string` | n/a | yes |
| region | GCP Region | `string` | `europe-west4` | no |
| zone | GCP Zone | `string` | `europe-west4-a` | no |
| machine_type | GCE Machine Type | `string` | `g2-standard-4` | no |
| is_spot | Use Spot instance | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| iap_tunnel_command | Commande pour ouvrir le tunnel IAP vers le LLM |
| chat_command | Commande pour interroger le modèle via Task |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 7.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | 7.46.2 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_cloud_nat"></a> [cloud\_nat](#module\_cloud\_nat) | terraform-google-modules/cloud-nat/google | ~> 7.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-google-modules/network/google | ~> 18.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [google_compute_firewall.allow_iap](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.llm_node](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_resource_policy.llm_schedule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_resource_policy) | resource |
| [google_project_iam_member.compute_agent_scheduler](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.logging](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.monitoring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.llm_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_gpu_count"></a> [gpu\_count](#input\_gpu\_count) | Number of GPUs | `number` | `1` | no |
| <a name="input_gpu_type"></a> [gpu\_type](#input\_gpu\_type) | GPU Type | `string` | `"nvidia-l4"` | no |
| <a name="input_is_spot"></a> [is\_spot](#input\_is\_spot) | Whether to use Spot instance for cost reduction | `bool` | `false` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | GCE Machine Type (G2 series for L4 GPU) | `string` | `"g2-standard-8"` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix for the resource names (e.g. -dev or -test). | `string` | `"-sample"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP Region (Default to Netherlands as L4 is more available there) | `string` | `"europe-west4"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | GCP Zone | `string` | `"europe-west4-a"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_api_instructions"></a> [api\_instructions](#output\_api\_instructions) | Instructions to call the Ollama API once the IAP tunnel is active |
| <a name="output_iap_ssh_command"></a> [iap\_ssh\_command](#output\_iap\_ssh\_command) | Connect to the instance via IAP SSH tunnel |
| <a name="output_iap_tunnel_command"></a> [iap\_tunnel\_command](#output\_iap\_tunnel\_command) | Create a secure tunnel to access the LLM API locally without a public IP |
| <a name="output_instance_name"></a> [instance\_name](#output\_instance\_name) | Name of the deployed GCE instance |
| <a name="output_instance_private_ip"></a> [instance\_private\_ip](#output\_instance\_private\_ip) | Private IP address of the GCE instance |
<!-- END_TF_DOCS -->