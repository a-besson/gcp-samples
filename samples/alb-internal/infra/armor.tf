# --- Plan de priorités Cloud Armor ---
# Cloud Armor arrête l'évaluation à la PREMIÈRE règle qui matche. La règle 900
# sert à la fois de rate-limit ET d'allow pour subnet-isolated : toute règle
# WAF déclarée AU-DESSUS de 900 (numériquement supérieure) serait donc du code
# mort. C'est l'invariant porteur de ce fichier, vérifié par un test dans
# tests/unit.tftest.hcl.
#
#   100–299   deny explicites (bannissements manuels) — inutilisé pour l'instant
#   300–499   rulesets WAF en `preview` (journalisés, non bloquants)
#   500–899   rulesets WAF appliqués
#   900       rate-limit + ban + allow subnet-isolated
#   2000      deny-by-default
#
# En production, cette bande 300–499 accueille les rulesets `*-canary` en
# miroir des `*-stable` appliqués (reco Google : « maintain canary rulesets in
# preview mode with a higher priority »). Ils ne sont pas dupliqués ici :
# Cloud Armor facture à la règle, et ce sample est un support pédagogique
# détruit/recréé. La bande est utilisée pour le seul ruleset dont le risque de
# faux positif n'est pas vérifiable hors-ligne (cf. `scannerdetection`).

resource "google_compute_region_security_policy" "api" {
  name        = "alb-internal-armor${var.name_suffix}"
  project     = var.project_id
  region      = var.region
  description = "Regional Cloud Armor policy for the alb-internal API backend service"
  type        = "CLOUD_ARMOR"

  # L'API ne parle que JSON (`POST /api/items`, `@RequestBody`). Sans ce bloc,
  # `json_parsing` vaut DISABLED (défaut de l'API GCP) et Cloud Armor évalue le
  # corps de requête comme une chaîne plate uniforme : les caractères
  # structurels du JSON déclenchent alors des faux positifs sur du trafic
  # légitime, et les contournements SQLi encodés en JSON passent.
  #
  # `request_body_inspection_size` n'est volontairement pas déclaré : le défaut
  # est déjà 64 kB, soit le maximum configurable (et le champ n'existe qu'en
  # google-beta, alors que cette policy est sur le provider GA).
  advanced_options_config {
    json_parsing = "STANDARD"
  }

  depends_on = [module.project_services]
}

# --- Rulesets WAF préconfigurés ---
# CRS 4.22 (`-v422-stable`) et non CRS 3.3 (`-v33-stable`) : c'est la
# génération courante, et surtout CRS 3.3 n'inclut PAS le ruleset `java`
# (« Not included » dans la doc Google), central pour une application Spring
# Boot / Java 25.
#
# `{'sensitivity': 1}` partout, via `evaluatePreconfiguredWaf` et non
# `evaluatePreconfiguredExpr` : ce dernier hérite du défaut implicite
# sensibilité 4 (toutes les signatures, paranoia level 4 OWASP), beaucoup trop
# bruyant pour une première mise en service. Reco Google : « start with
# sensitivity level 1 in preview mode ». Chaque ruleset retenu ci-dessous
# possède au moins une signature de niveau 1, donc aucun n'est silencieusement
# vidé par ce réglage.
#
# Pour neutraliser un faux positif précis SANS désactiver tout le ruleset,
# ajouter un bloc `preconfigured_waf_config { exclusion { target_rule_ids } }`
# sur la règle concernée — jamais abaisser la sensibilité globalement.
#
# Rulesets volontairement écartés, hors modèle de menace de ce sample :
#   - lfi / rfi         : aucun service de fichiers, 2 endpoints REST
#   - php / nodejs      : stack Java
#   - sessionfixation   : pas de session applicative, IAP en amont
#   - json-sqli-canary  : couverture largement recouverte par la signature
#                         942550 (« JSON-Based SQL injection »), déjà incluse
#                         au niveau 1 dans sqli-v422-stable. La variante
#                         canary est un peu plus large (elle couvre aussi les
#                         vecteurs SQLi présents dans l'URL) mais ne justifie
#                         pas une règle facturée de plus ici.
locals {
  armor_waf_rules = {
    # --- Appliqués (500–899) ---
    sqli = {
      priority    = 500
      ruleset     = "sqli-v422-stable"
      preview     = false
      description = "Preconfigured WAF: SQL injection (includes JSON-based SQLi signature 942550)"
    }
    xss = {
      priority    = 510
      ruleset     = "xss-v422-stable"
      preview     = false
      description = "Preconfigured WAF: cross-site scripting"
    }
    rce = {
      priority    = 520
      ruleset     = "rce-v422-stable"
      preview     = false
      description = "Preconfigured WAF: remote code execution"
    }
    # Le ruleset le plus pertinent pour cette stack : désérialisation Java
    # (CVE-2015-4852), Struts (CVE-2017-9805) et Log4Shell (signature 944150).
    java = {
      priority    = 530
      ruleset     = "java-v422-stable"
      preview     = false
      description = "Preconfigured WAF: Java attacks (deserialization, Log4Shell) - Spring Boot stack"
    }
    # Request smuggling / response splitting : pertinent vu la chaîne de proxies
    # Envoy managés (subnet-proxy-only) devant Cloud Run.
    protocolattack = {
      priority    = 540
      ruleset     = "protocolattack-v422-stable"
      preview     = false
      description = "Preconfigured WAF: HTTP protocol attacks (request smuggling, response splitting)"
    }
    # Signature unique 911100 « Method isn't allowed by policy ». L'API
    # n'expose que GET et POST (ItemController) : aligné aujourd'hui.
    #
    # > [!WARNING]
    # > C'est la seule règle ajoutée qui puisse bloquer du trafic LÉGITIME, et
    # > `task e2e-cyber` ne peut pas le détecter (il n'envoie que GET et POST).
    # > À revérifier si l'API expose un jour PUT / DELETE / PATCH.
    methodenforcement = {
      priority    = 550
      ruleset     = "methodenforcement-v422-stable"
      preview     = false
      description = "Preconfigured WAF: HTTP method enforcement (API exposes GET + POST only)"
    }
    # Complète `java` sur Log4Shell : apporte les signatures Google 044228 et
    # 144228 (couverture des tentatives d'obfuscation et de contournement).
    cve_canary = {
      priority    = 560
      ruleset     = "cve-canary"
      preview     = false
      description = "Preconfigured WAF: Log4j CVE-2021-44228/45046 bypass and obfuscation coverage"
    }

    # --- En preview (300–499) ---
    # Une règle en `preview` journalise sans agir ET SANS INTERROMPRE
    # l'évaluation : le trafic continue vers la règle 900 qui l'autorise. C'est
    # ce qui rend cette bande sûre. Confirmation : un même log Cloud Armor
    # porte à la fois `previewSecurityPolicy` et `enforcedSecurityPolicy`, ce
    # qui n'aurait pas de sens si un match en preview arrêtait la chaîne.
    #
    # Signature unique 913100 « Found user-agent associated with security
    # scanner ». Or `task e2e` et `task e2e-cyber` interrogent l'API avec curl
    # depuis la VM cliente : le risque de faux positif sur le trafic légitime
    # de ce sample est réel et NON vérifiable hors-ligne. La règle journalise
    # donc sans bloquer — voir la métrique `armor-preview-matched`
    # (monitoring.tf) pour décider de son passage en appliqué.
    scannerdetection = {
      priority    = 400
      ruleset     = "scannerdetection-v422-stable"
      preview     = true
      description = "Preconfigured WAF (PREVIEW): scanner detection - observe before enforcing, curl-based e2e tests may match"
    }
  }
}

resource "google_compute_region_security_policy_rule" "waf" {
  for_each = local.armor_waf_rules

  project         = var.project_id
  region          = var.region
  security_policy = google_compute_region_security_policy.api.name
  priority        = each.value.priority
  action          = "deny(403)"
  preview         = each.value.preview
  description     = each.value.description

  match {
    expr {
      expression = "evaluatePreconfiguredWaf('${each.value.ruleset}', {'sensitivity': 1})"
    }
  }
}

# Rate-limite, bannit ET autorise le trafic issu de subnet-isolated - la seule
# source légitime (VM cliente / VIP de l'ILB). Cloud Armor s'arrête à la
# première règle qui matche : cette règle unique fait donc à la fois le
# rate-limit et l'allow ; une règle « allow » distincte à une priorité
# inférieure ne serait jamais atteinte et n'est donc pas déclarée. Scoper le
# match à subnet-isolated (et non "*") est ce qui garde le deny-by-default de
# priorité 2000 réellement atteignable pour toute autre source.
#
# `rate_based_ban` et non `throttle` : un simple throttle laisse l'attaquant
# sonder indéfiniment à exactement 100 req/min, ce qui est précisément le
# scénario d'énumération lente depuis une VM compromise. Le ban coupe la
# session pour 10 minutes.
#
# Calibrage : `task e2e-cyber` envoie ~120 requêtes par exécution. Le seuil de
# ban (600 req / 5 min) laisse donc passer 5 exécutions consécutives du test
# avant bannissement, tout en restant très en dessous d'un débit
# d'énumération.
resource "google_compute_region_security_policy_rule" "rate_limit" {
  project         = var.project_id
  region          = var.region
  security_policy = google_compute_region_security_policy.api.name
  priority        = 900
  action          = "rate_based_ban"
  description     = "Rate limit + ban + allow: 100 req/min per source IP, subnet-isolated only"
  match {
    versioned_expr = "SRC_IPS_V1"
    config {
      src_ip_ranges = [var.vpc_cidr_isolated]
    }
  }
  rate_limit_options {
    conform_action = "allow"
    exceed_action  = "deny(429)"
    enforce_on_key = "IP"
    rate_limit_threshold {
      count        = 100
      interval_sec = 60
    }
    ban_threshold {
      count        = 600
      interval_sec = 300
    }
    ban_duration_sec = 600
  }
}

# Explicit deny-by-default. Not declared at priority 2147483647: the policy
# already auto-creates an allow rule at that exact priority, and re-declaring
# it would fail the apply with a 409. This deny at 2000 produces the same
# deny-by-default semantics for every source not matched above.
resource "google_compute_region_security_policy_rule" "deny_default" {
  project         = var.project_id
  region          = var.region
  security_policy = google_compute_region_security_policy.api.name
  priority        = 2000
  action          = "deny(403)"
  description     = "Deny by default: only subnet-isolated is allowed through"
  match {
    versioned_expr = "SRC_IPS_V1"
    config {
      src_ip_ranges = ["*"]
    }
  }
}
