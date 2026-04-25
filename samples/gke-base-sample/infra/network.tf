# --- Network ---
# VPC and subnets are pre-provisioned in the 'base' module.
# We reference them via remote state to ensure consistency.
data "terraform_remote_state" "base" {
  backend = "gcs"
  config = {
    bucket = "${var.project_id}-tfstate"
    prefix = "base"
  }
}
