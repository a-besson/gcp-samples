# --- Détection des blocages Cloud Armor ---
# `log_config { enable = true, sample_rate = 1.0 }` est déjà actif sur le
# backend service (loadbalancer.tf) : les logs Cloud Armor existent déjà et
# sont déjà payés, il ne manquait que leur exploitation.
#
# Sous le modèle de menace réel de ce sample - le VIP n'est joignable que
# depuis subnet-isolated, donc l'attaquant pertinent est une VM cliente
# compromise ou un insider - la DÉTECTION prime sur l'ajout de règles WAF
# supplémentaires : un blocage que personne ne voit ne fait que ralentir
# l'attaquant.
#
# > [!IMPORTANT]
# > `resource.type = "internal_http_lb_rule"` est le type de ressource
# > monitorée des ALB internes (confirmé dans la liste officielle des
# > monitored resources). La page « Cloud Armor request logging » ne décrit
# > toutefois explicitement que les ALB externes : à confirmer au premier
# > `apply` via Logs Explorer si aucune métrique ne remonte.

resource "google_logging_metric" "armor_denied" {
  name        = "alb-internal-armor-denied${var.name_suffix}"
  project     = var.project_id
  description = "Requests denied by the alb-internal Cloud Armor policy (enforced rules only)"

  filter = join(" AND ", [
    "resource.type=\"internal_http_lb_rule\"",
    "jsonPayload.enforcedSecurityPolicy.outcome=\"DENY\"",
  ])

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    # La priorité de la règle déclenchée est extraite en label : c'est elle qui
    # permet de distinguer un blocage WAF (500–899) d'un dépassement de
    # rate-limit (900) ou d'une source non autorisée (2000) sans rouvrir les
    # logs bruts.
    labels {
      key         = "rule_priority"
      value_type  = "STRING"
      description = "Priority of the Cloud Armor rule that denied the request"
    }
  }

  label_extractors = {
    rule_priority = "EXTRACT(jsonPayload.enforcedSecurityPolicy.priority)"
  }

  depends_on = [module.project_services]
}

# Les règles en `preview` (bande 300–499, cf. armor.tf) ne journalisent PAS
# sous `enforcedSecurityPolicy` mais sous `previewSecurityPolicy`. Sans cette
# seconde métrique, la règle scannerdetection en preview serait inobservable -
# donc inutile, puisqu'on ne pourrait jamais décider de l'appliquer.
# Volontairement non alertée : c'est un signal d'observation, pas un incident.
resource "google_logging_metric" "armor_preview_matched" {
  name        = "alb-internal-armor-preview-matched${var.name_suffix}"
  project     = var.project_id
  description = "Requests that WOULD have been denied by a Cloud Armor rule running in preview mode"

  filter = join(" AND ", [
    "resource.type=\"internal_http_lb_rule\"",
    "jsonPayload.previewSecurityPolicy.outcome=\"DENY\"",
  ])

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    labels {
      key         = "rule_priority"
      value_type  = "STRING"
      description = "Priority of the preview-mode Cloud Armor rule that matched"
    }
  }

  label_extractors = {
    rule_priority = "EXTRACT(jsonPayload.previewSecurityPolicy.priority)"
  }

  depends_on = [module.project_services]
}

# Seuil à 50 blocages / 5 min : `task e2e-cyber` en génère ~23 par exécution
# (2 WAF en query string + 1 WAF en corps JSON + jusqu'à 20 réponses 429 du
# rate-limit). Une exécution du test ne déclenche donc pas l'alerte, ni deux
# (~46) ; trois exécutions dans la même fenêtre (~69) la déclenchent, comme
# une véritable énumération.
resource "google_monitoring_alert_policy" "armor_denied" {
  project      = var.project_id
  display_name = "alb-internal - Cloud Armor blocked traffic${var.name_suffix}"
  combiner     = "OR"

  conditions {
    display_name = "Cloud Armor denials > 50 per 5 min"
    condition_threshold {
      # The Monitoring API rejects a condition filter on a user-defined
      # log-based metric without an explicit resource.type restriction
      # (metric.type alone isn't enough), even though the metric itself is
      # already scoped to internal_http_lb_rule above.
      filter          = "resource.type=\"internal_http_lb_rule\" AND metric.type=\"logging.googleapis.com/user/${google_logging_metric.armor_denied.name}\""
      comparison      = "COMPARISON_GT"
      threshold_value = 50
      duration        = "0s"
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_SUM"
      }
      trigger {
        count = 1
      }
    }
  }

  documentation {
    content   = <<-EOT
      Cloud Armor a bloqué un volume anormal de requêtes sur l'API alb-internal.

      Le VIP de l'ALB n'étant joignable que depuis subnet-isolated, une rafale
      de blocages signale une source INTERNE au VPC : VM cliente compromise,
      dépendance malveillante, ou test de sécurité non annoncé.

      Triage :
      1. Label `rule_priority` de la métrique :
         500–899 = signature WAF, 900 = rate-limit/ban, 2000 = source non autorisée.
      2. Logs Explorer :
         resource.type="internal_http_lb_rule" jsonPayload.enforcedSecurityPolicy.outcome="DENY"
      3. Identifier la source dans `httpRequest.remoteIp` et la corréler avec
         les instances de subnet-isolated.
    EOT
    mime_type = "text/markdown"
  }

  notification_channels = var.alert_notification_channels

  depends_on = [module.project_services]
}
