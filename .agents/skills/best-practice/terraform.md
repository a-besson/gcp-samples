# Terraform Best Practices

Mandatory IaC standards for all Terraform code in this repository.

## Required Standards

1. **Modular Structure**: Terraform resources must be logically split by service (e.g., `cloudrun.tf`, `iam.tf`, `network.tf`). Monolithic `main.tf` files are forbidden.
2. **Standard Modules First**: Always check for official modules before writing resources from scratch (e.g., `terraform-google-modules`, `terraform-aws-modules`).
3. **Version Pinning**: All provider and module versions must be strictly pinned (e.g., `version = "~> x.y"`).
4. **Variable Validation**: Every input variable that could cause an infrastructure error must have a `validation {}` block.
5. **Security & Isolation**:
   - Disable public IPs by default; use private subnets.
   - Apply least privilege in IAM bindings. Avoid `editor` or `owner` roles.
   - Always use remote state with encryption at rest.
6. **Resource Labeling & Tagging (GCP)**:
   - Always define standard `default_labels` on the Google provider in `providers.tf` (`env`, `project`, `managed-by`, `owner`).
   - **Mandatory Prefix**: The `project` label value MUST be prefixed with `gcp-samples_` (e.g., `gcp-samples_base`, `gcp-samples_cloudrun-job`).
   - Slashes (`/`) are forbidden by GCP label constraints; use an underscore (`_`) after the project name to separate the sample.
   - Resource-level `labels` should only contain unique resource-specific labels (e.g., `role = "web-server"`) and must never duplicate provider-level `default_labels` to prevent configuration noise and drift.
   - Use `user_labels` block for `google_sql_database_instance` and `cluster_resource_labels` for GKE modules.

