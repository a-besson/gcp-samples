# http_check

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.50 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.27.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_service_account_id_token.token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account_id_token) | data source |
| [http_http.health_check](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tester_sa_email"></a> [tester\_sa\_email](#input\_tester\_sa\_email) | n/a | `string` | n/a | yes |
| <a name="input_url"></a> [url](#input\_url) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_body"></a> [body](#output\_body) | n/a |
| <a name="output_status"></a> [status](#output\_status) | n/a |
<!-- END_TF_DOCS -->
