# Cost guardrail — zero-cost defense against runaway spend (cost-based DoS,
# leaked virtual key, scaling storms). Created only when var.billing_account is
# set. With no all_updates_rule, alert emails go to the billing account
# admins/users by default (no PII or notification channel required).
#
# Prereq: the IaC service account (sa-iac) needs roles/billing.costsManager on
# the billing account, otherwise apply fails with a 403.
resource "google_billing_budget" "litellm" {
  count           = var.billing_account != "" ? 1 : 0
  billing_account = var.billing_account
  display_name    = "litellm-proxy${var.name_suffix}"

  # Scope the budget to this project only.
  budget_filter {
    projects = ["projects/${data.google_project.this.number}"]
  }

  # currency_code omitted on purpose: inherits the billing account currency to
  # avoid a mismatch error.
  amount {
    specified_amount {
      units = tostring(var.monthly_budget_amount)
    }
  }

  threshold_rules {
    threshold_percent = 0.5
  }
  threshold_rules {
    threshold_percent = 0.9
  }
  threshold_rules {
    threshold_percent = 1.0
  }

  depends_on = [module.project_services]
}
