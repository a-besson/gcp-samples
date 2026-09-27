# --- E2E Tests for Cloud Run SSL Service ---
# This test applies the infrastructure and then performs an authenticated
# request to the service URL to verify it's reachable and responds with 200 OK.

variables {
  name_suffix = "-e2etest"
}

run "apply_infrastructure" {
  command = apply
}

run "verify_authenticated_access" {
  command = apply

  variables {
    url             = run.apply_infrastructure.exposed_service_url
    tester_sa_email = run.apply_infrastructure.tester_sa_email
  }

  module {
    source = "./tests/helpers/http_check"
  }

  assert {
    condition     = output.status == 200
    error_message = "Health check failed with status ${output.status}"
  }
}
