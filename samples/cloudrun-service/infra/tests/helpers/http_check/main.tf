variable "url" {
  type = string
}

variable "tester_sa_email" {
  type = string
}

data "google_service_account_id_token" "token" {
  # Use the SA email provided as output from the apply run
  target_service_account = var.tester_sa_email
  target_audience        = var.url
}

data "http" "health_check" {
  url = var.url
  request_headers = {
    Authorization = "Bearer ${data.google_service_account_id_token.token.id_token}"
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Authentication failed: service returned ${self.status_code} instead of 200"
    }
  }
}

output "status" {
  value = data.http.health_check.status_code
}

output "body" {
  value = data.http.health_check.response_body
}
