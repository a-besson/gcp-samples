module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"

  project_id   = var.project_id
  network_name = local.vpc_name
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = var.subnet_public_name
      subnet_ip             = var.subnet_public_ip
      subnet_region         = var.region
      subnet_private_access = "false"
    },
    {
      subnet_name           = var.subnet_priv_a_name
      subnet_ip             = var.subnet_priv_a_ip
      subnet_region         = var.region
      subnet_private_access = "true"
    },
    {
      subnet_name           = var.subnet_priv_b_name
      subnet_ip             = var.subnet_priv_b_ip
      subnet_region         = var.region
      subnet_private_access = "true"
    }
  ]
}
