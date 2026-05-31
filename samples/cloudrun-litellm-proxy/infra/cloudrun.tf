resource "google_cloud_run_v2_service" "litellm" {
  name                = "${var.service_name}${var.name_suffix}"
  location            = var.region
  project             = var.project_id
  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

  template {
    service_account = google_service_account.litellm_runner.email

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    # Public subnet: Cloud Run is internet-reachable. Egress PRIVATE_RANGES_ONLY
    # ensures Vertex AI and Cloud SQL (private IP) go through the Google backbone.
    vpc_access {
      network_interfaces {
        network    = data.terraform_remote_state.base.outputs.network_name
        subnetwork = data.terraform_remote_state.base.outputs.subnet_public.name
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

    # Cloud SQL Auth Proxy sidecar — tunnels the Postgres connection.
    # LiteLLM (container "litellm") connects to localhost:5432.
    containers {
      name  = "cloud-sql-proxy"
      image = "gcr.io/cloud-sql-connectors/cloud-sql-proxy:2"
      args = [
        "--structured-logs",
        "--port=5432",
        "--private-ip",
        "--health-check",
        "--http-address=0.0.0.0",
        "--http-port=9090",
        module.cloudsql.instance_connection_name,
      ]

      resources {
        limits = {
          cpu    = "0.5"
          memory = "256Mi"
        }
        cpu_idle = false
      }

      startup_probe {
        http_get {
          path = "/startup"
          port = 9090
        }
        initial_delay_seconds = 5
        period_seconds        = 5
        timeout_seconds       = 3
        failure_threshold     = 5
      }
    }

    containers {
      name  = "litellm"
      image = var.image_service

      # Start after the proxy is healthy so DATABASE_URL connections succeed.
      depends_on = ["cloud-sql-proxy"]

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
        cpu_idle          = false
        startup_cpu_boost = true
      }

      ports {
        container_port = 4000
      }

      env {
        name  = "LITELLM_CONFIG_PATH"
        value = "/app/config.yaml"
      }
      # Control-plane hardening: disable the browser Admin UI (/ui) since the
      # service is publicly reachable (allUsers). Key/user management is done
      # via Terraform (litellm provider) and the master-key-protected Admin API.
      # NOTE: do NOT set DISABLE_ADMIN_ENDPOINTS — it would break Terraform.
      env {
        name  = "DISABLE_ADMIN_UI"
        value = "True"
      }
      env {
        name  = "VERTEXAI_PROJECT"
        value = var.project_id
      }
      env {
        name  = "VERTEXAI_LOCATION"
        value = var.vertex_location
      }
      env {
        name = "LITELLM_MASTER_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.master_key.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.database_url.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "BIGQUERY_DATASET"
        value = var.bigquery_dataset
      }
      env {
        name  = "BIGQUERY_PROJECT"
        value = var.project_id
      }

      startup_probe {
        http_get {
          path = "/health/liveliness"
          http_headers {
            name  = "x-api-key"
            value = "Bearer sk-dummy"
          }
        }
        initial_delay_seconds = 15
        period_seconds        = 5
        timeout_seconds       = 3
        failure_threshold     = 10
      }

      liveness_probe {
        http_get {
          path = "/health/liveliness"
          http_headers {
            name  = "x-api-key"
            value = "Bearer sk-dummy"
          }
        }
        period_seconds    = 30
        timeout_seconds   = 3
        failure_threshold = 3
      }
    }
  }

  depends_on = [
    module.project_services,
    google_secret_manager_secret.master_key,
    google_secret_manager_secret_version.database_url,
  ]
}
