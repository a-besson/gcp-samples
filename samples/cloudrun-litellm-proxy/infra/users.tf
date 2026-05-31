# User-managed LiteLLM Virtual Keys.
# Reads users.yaml and creates one litellm_key per user entry.
# Keys are synchronized on every `terraform apply`.

locals {
  users_config = yamldecode(file("${path.module}/../users.yaml"))
  users_map = {
    for user in local.users_config.users : user.name => user
  }
}

resource "litellm_key" "user" {
  for_each = local.users_map

  key_alias       = each.key
  max_budget      = each.value.budget
  budget_duration = each.value.duration
  models          = try(each.value.models, ["all-proxy-models"])

  metadata = {
    user       = each.key
    managed_by = "terraform"
  }

  depends_on = [google_cloud_run_v2_service.litellm]
}
