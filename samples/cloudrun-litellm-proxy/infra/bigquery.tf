resource "google_bigquery_dataset" "litellm" {
  dataset_id                 = var.bigquery_dataset
  location                   = var.region
  project                    = var.project_id
  description                = "LiteLLM Proxy — tokens, cost, and latency per request."
  delete_contents_on_destroy = false
  depends_on                 = [module.project_services]
}

resource "google_bigquery_table" "litellm_logs" {
  dataset_id          = google_bigquery_dataset.litellm.dataset_id
  table_id            = "litellm_logs"
  project             = var.project_id
  deletion_protection = false

  time_partitioning {
    type  = "DAY"
    field = "created_at"
  }

  schema = jsonencode([
    { name = "request_id", type = "STRING", mode = "NULLABLE" },
    { name = "model", type = "STRING", mode = "NULLABLE" },
    { name = "input_tokens", type = "INTEGER", mode = "NULLABLE" },
    { name = "output_tokens", type = "INTEGER", mode = "NULLABLE" },
    { name = "total_tokens", type = "INTEGER", mode = "NULLABLE" },
    { name = "spend", type = "FLOAT64", mode = "NULLABLE" },
    { name = "response_ms", type = "FLOAT64", mode = "NULLABLE" },
    { name = "user", type = "STRING", mode = "NULLABLE" },
    { name = "key_alias", type = "STRING", mode = "NULLABLE" },
    { name = "team", type = "STRING", mode = "NULLABLE" },
    { name = "created_at", type = "TIMESTAMP", mode = "NULLABLE" },
  ])
}
