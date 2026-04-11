output "network_name" {
  description = "The name of the VPC being created"
  value       = module.vpc.network_name
}

output "network_self_link" {
  description = "The URI of the VPC being created"
  value       = module.vpc.network_self_link
}

output "subnet_public" {
  description = "The public subnet details"
  value       = module.vpc.subnets["${var.region}/${var.subnet_public_name}${var.name_suffix}"]
}

output "subnet_priv_a" {
  description = "private subnet A details"
  value       = module.vpc.subnets["${var.region}/${var.subnet_priv_a_name}${var.name_suffix}"]
}

output "subnet_priv_b" {
  description = "private subnet B details"
  value       = module.vpc.subnets["${var.region}/${var.subnet_priv_b_name}${var.name_suffix}"]
}

output "terraform_state_bucket" {
  description = "The GCS bucket name used for Terraform remote state"
  value       = "${var.project_id}-tfstate"
}

output "bastion_repo_name" {
  description = "The Artifact Registry repository name for the bastion"
  value       = module.artifact_registry_bastion.artifact_name
}
