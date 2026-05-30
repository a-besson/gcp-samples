resource "google_monitoring_dashboard" "litellm" {
  project = var.project_id

  dashboard_json = jsonencode({
    displayName = "LiteLLM Proxy — ${var.service_name}${var.name_suffix}"
    mosaicLayout = {
      columns = 12
      tiles = [
        {
          xPos   = 0
          yPos   = 0
          width  = 6
          height = 4
          widget = {
            title = "Request Rate (req/s)"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"run.googleapis.com/request_count\" resource.type=\"cloud_run_revision\" resource.label.\"service_name\"=\"${var.service_name}${var.name_suffix}\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_RATE"
                      crossSeriesReducer = "REDUCE_SUM"
                      groupByFields      = ["metric.label.response_code_class"]
                    }
                  }
                  unitOverride = "1/s"
                }
                plotType = "LINE"
              }]
            }
          }
        },
        {
          xPos   = 6
          yPos   = 0
          width  = 6
          height = 4
          widget = {
            title = "Request Latency P99 (ms)"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "metric.type=\"run.googleapis.com/request_latencies\" resource.type=\"cloud_run_revision\" resource.label.\"service_name\"=\"${var.service_name}${var.name_suffix}\""
                      aggregation = {
                        alignmentPeriod    = "60s"
                        perSeriesAligner   = "ALIGN_DELTA"
                        crossSeriesReducer = "REDUCE_PERCENTILE_99"
                      }
                    }
                  }
                  plotType       = "LINE"
                  legendTemplate = "P99"
                },
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "metric.type=\"run.googleapis.com/request_latencies\" resource.type=\"cloud_run_revision\" resource.label.\"service_name\"=\"${var.service_name}${var.name_suffix}\""
                      aggregation = {
                        alignmentPeriod    = "60s"
                        perSeriesAligner   = "ALIGN_DELTA"
                        crossSeriesReducer = "REDUCE_PERCENTILE_50"
                      }
                    }
                  }
                  plotType       = "LINE"
                  legendTemplate = "P50"
                }
              ]
            }
          }
        },
        {
          xPos   = 0
          yPos   = 4
          width  = 6
          height = 4
          widget = {
            title = "Instance Count"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"run.googleapis.com/container/instance_count\" resource.type=\"cloud_run_revision\" resource.label.\"service_name\"=\"${var.service_name}${var.name_suffix}\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_MAX"
                      crossSeriesReducer = "REDUCE_SUM"
                    }
                  }
                }
                plotType = "STACKED_BAR"
              }]
            }
          }
        },
        {
          xPos   = 6
          yPos   = 4
          width  = 6
          height = 4
          widget = {
            title = "Token & Cost Analytics — BigQuery"
            text = {
              content = "**Token and cost data** is written to BigQuery by LiteLLM's `success_callback`.\n\nDataset: `${var.bigquery_dataset}` · Table: `litellm_logs`\n\n```sql\nSELECT\n  DATE(created_at)     AS day,\n  model,\n  SUM(input_tokens)    AS read_tokens,\n  SUM(output_tokens)   AS write_tokens,\n  ROUND(SUM(spend), 6) AS cost_usd,\n  ROUND(AVG(response_ms)) AS avg_ms\nFROM `${var.project_id}.${var.bigquery_dataset}.litellm_logs`\nWHERE created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)\nGROUP BY 1, 2\nORDER BY 1 DESC;\n```\n\nRun via: `task query-spend`"
              format  = "MARKDOWN"
            }
          }
        }
      ]
    }
  })

  depends_on = [module.project_services]
}
