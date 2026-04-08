locals {
  # Base VPC naming convention with optional suffix for testing/uniqueness
  vpc_name = "gcp-sample-base-vpc${var.name_suffix}"
}
