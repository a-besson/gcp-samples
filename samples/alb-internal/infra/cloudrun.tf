resource "google_cloud_run_v2_service" "api" {
  name                = "alb-internal-api${var.name_suffix}"
  location            = var.region
  project             = var.project_id
  ingress             = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER" # only the ILB can reach this service
  deletion_protection = false

  template {
    service_account = google_service_account.api.email
    encryption_key  = data.terraform_remote_state.bootstrap.outputs.kms_key_run

    # Direct VPC Egress into subnet-isolated-application. `tags` is the only
    # per-workload firewall selector available here (Cloud Run's NIC carries
    # no service account for `target_service_accounts` to match).
    vpc_access {
      network_interfaces {
        network    = google_compute_network.vpc.id
        subnetwork = google_compute_subnetwork.application.id
        tags       = ["alb-internal-api"]
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

    containers {
      name  = "cloud-sql-proxy"
      image = "gcr.io/cloud-sql-connectors/cloud-sql-proxy:2"
      args = [
        "--structured-logs",
        "--port=5432",
        "--psc", # mandatory: connect via the PSC endpoint, not a private IP
        "--health-check",
        "--http-address=0.0.0.0",
        "--http-port=9090",
        google_sql_database_instance.app.connection_name,
      ]
      startup_probe {
        http_get {
          path = "/startup"
          port = 9090
        }
        initial_delay_seconds = 0
        period_seconds        = 5
        failure_threshold     = 20
      }
      liveness_probe {
        http_get {
          path = "/liveness"
          port = 9090
        }
        period_seconds = 30
      }
      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }

    containers {
      name       = "api"
      image      = local.image_url
      depends_on = ["cloud-sql-proxy"] # wait for the sidecar to report healthy before starting
      ports {
        container_port = 8080
      }
      env {
        name  = "DB_NAME"
        value = google_sql_database.app.name
      }
      env {
        name  = "DB_USER"
        value = google_sql_user.app.name
      }
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
      startup_probe {
        http_get {
          path = "/actuator/health/readiness"
          port = 8080
        }
        initial_delay_seconds = 0
        period_seconds        = 5
        failure_threshold     = 20
      }
      liveness_probe {
        http_get {
          path = "/actuator/health/liveness"
          port = 8080
        }
        period_seconds = 30
      }
      resources {
        limits = {
          cpu    = "1"
          memory = "1Gi"
        }
        startup_cpu_boost = true
      }
    }

    scaling {
      min_instance_count = 0 # scale-to-zero: FinOps
      max_instance_count = 3
    }
  }

  depends_on = [module.project_services]
}
