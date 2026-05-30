# 📝 Todo List - GCP Samples

## 🚀 Model Garden API Gateway (Apigee)

**Objectif :** Déployer une passerelle d'API souveraine (europe-west9) via Apigee pour sécuriser, monitorer et facturer l'accès aux modèles Vertex AI (Gemini, Claude, Gemma).

---

### 🎯 Prompt Optimisé (Master Blueprint - Apigee)

> [!IMPORTANT]
> Agis en tant qu'Architecte Cloud Expert GCP & Apigee. Ta mission est de générer un module de référence complet pour `samples/apigee-model-garden`.

#### 🏗️ Architecture & Structure
Génère la structure de fichiers suivante :
- `infra/` : Fichiers Terraform pour l'approvisionnement (Proxy, Product, App).
- `bundle/` : Structure standard d'un bundle Apigee (apiproxy, targets, proxies, policies, resources/jsc).
- `README.md` : Documentation technique et guide de déploiement.

#### 🛠️ Spécifications Techniques

| Composant | Détails de l'implémentation |
| :--- | :--- |
| **Sécurité (PreFlow)** | `SpikeArrest` (30pm), `VerifyAPIKey` (header `X-API-Key`), `CORS`. |
| **Contrôle Budgétaire** | `Quota` initial (weight 0) basé sur `developer.app.id` (Budget: 100€/jour). |
| **Target Endpoint** | `europe-west9-aiplatform.googleapis.com`. Auth: `GoogleAccessToken` (scope cloud-platform). |
| **Routage Dynamique** | Extraction du modèle via path (ex: `/v1/models/{model}:predict`). |
| **Observabilité** | `ExtractVariables` (JSONPath) pour `usageMetadata` (prompt/candidates tokens). |
| **Calcul du Coût (JS)** | Script `JS-CalculateCost.js` avec table de prix par modèle. Sortie : `weight` (Prix * 100,000). |
| **Logging** | `MessageLogging` vers Cloud Logging avec payload JSON structuré. |

#### 📝 Contraintes de Code
1. **Naming :** Utiliser les préfixes standards (SA-, VAK-, Q-, EV-, JS-, ML-).
2. **Terraform :** Utiliser les ressources `google_apigee_proxy`, `google_apigee_api_product`, etc.
3. **JS :** Optimiser pour la performance (éviter les regex lourdes, utiliser `JSON.parse`).

---

### 🎯 Prompt Optimisé (LiteLLM Proxy - Cloud Run) — v3

> [!IMPORTANT]
> Agis en tant qu'Architecte Cloud Expert GCP & DevOps.
>
> **Contexte :** Le sample `samples/cloudrun-litellm-proxy` peut exister ou non.
> - **S'il n'existe pas** : crée-le de zéro en respectant toutes les spécifications ci-dessous.
> - **S'il existe déjà** (v1 lean ou v2) : fais évoluer uniquement les fichiers qui changent. Identifie d'abord ce qui est déjà en place avant de modifier.
>
> **Exigences de cette version :**
> 1. **Authentification par API Key par utilisateur** (LiteLLM Virtual Keys via Cloud SQL Postgres).
> 2. **Accès réseau via le subnet public** du VPC base (exposition HTTPS publique).
> 3. **DNS custom** sur le service Cloud Run (domaine géré par Cloud DNS).
> 4. **Observabilité complète** : tokens lus/écrits, coût, durée → BigQuery + dashboard Cloud Monitoring.
> 5. **Catalogue de modèles complet** : Gemini 2.5, Claude 4.x (Opus/Sonnet/Haiku), Gemma 3.

#### 🏗️ Architecture & Structure cible

```
samples/cloudrun-litellm-proxy/
├── app/
│   ├── Dockerfile               # litellm v1.52.0+ pinned
│   └── config.yaml              # database_url, bigquery callback, virtual_keys
├── infra/
│   ├── providers.tf             # google ~> 6.0, random ~> 3.6
│   ├── variables.tf             # project_id, region, dns_name, cloudsql_tier, bigquery_dataset
│   ├── main.tf                  # APIs activées + locals DNS + locals observability
│   ├── iam.tf                   # runner SA + bindings (cloudsql, secrets, bigquery)
│   ├── secrets.tf               # LITELLM_MASTER_KEY + DATABASE_URL
│   ├── artifact_registry.tf     # Docker repo
│   ├── cloudsql.tf              # random_password, VPC peering, Postgres 15
│   ├── cloudrun.tf              # subnet_public, sidecar cloud-sql-proxy, env vars
│   ├── bigquery.tf              # NOUVEAU : dataset + table litellm_logs (schema explicite)
│   ├── observability.tf         # NOUVEAU : log-based metrics + dashboard Cloud Monitoring
│   ├── dns.tf                   # managed zone + CNAME → ghs.googlehosted.com
│   ├── domain_mapping.tf        # google_cloud_run_domain_mapping
│   └── outputs.tf               # + bigquery_dataset, dashboard_url
├── Taskfile.yml                 # seed-key, build, apply, provision-key, smoke, query-spend
└── README.md                    # architecture, auth, observabilité, DNS
```

#### 🛠️ Spécifications Techniques

| Composant | Détails de l'implémentation |
| :--- | :--- |
| **Compute** | Cloud Run v2, `min_instances=1`, CPU always-on, `startup_cpu_boost=true`. |
| **LiteLLM Core** | Proxy OpenAI-compatible vers Vertex AI. `stream: true` par défaut. `success_callback: ["bigquery"]`. `store_model_in_db: false`. |
| **Modèles** | **Gemini** : `gemini-2.5-pro`, `gemini-2.5-flash`. **Claude** : `claude-opus-4-7`, `claude-opus-4-6`, `claude-sonnet-4-6`, `claude-haiku-4-5`. **Gemma** : `gemma-3-1b`, `gemma-3-27b`. |
| **Régions d'inférence** | **Gemini + Claude** : `vertex_location: eu` (endpoint EU multi-région, GA). **Gemma** : `vertex_location: europe-west4` (Model Garden GPU endpoint). IDs Claude 4.x sans suffixe `@date` (dateless depuis 4.6). IDs Gemma : `vertex_ai/google/gemma3@gemma-3-{size}-it`. |
| **Auth utilisateur** | LiteLLM **Virtual Keys** : chaque utilisateur possède une clé `sk-...` générée via `POST /key/generate` (auth admin = `LITELLM_MASTER_KEY`). Quota et budget définis à la création. |
| **Backend Virtual Keys** | **Cloud SQL Postgres 15** (tier `db-f1-micro` pour dev). LiteLLM reçoit `DATABASE_URL` depuis Secret Manager. Runner SA : `roles/cloudsql.client`. Connexion via Cloud SQL Auth Proxy sidecar (localhost:5432). |
| **Réseautage** | Direct VPC Egress sur **`subnet_public`** (base outputs). `INGRESS_TRAFFIC_ALL`. Egress `PRIVATE_RANGES_ONLY` (Vertex + Cloud SQL via Google backbone). |
| **DNS** | `google_cloud_run_domain_mapping` + `google_dns_managed_zone` + CNAME → `ghs.googlehosted.com`. Variable `var.dns_name` (ex: `llm.example.com`). `count = var.dns_name != "" ? 1 : 0`. |
| **TLS** | Géré automatiquement par Cloud Run via domain mapping (cert Google-managed). |
| **Secrets** | `LITELLM_MASTER_KEY` (seed manuel, jamais dans le state). `DATABASE_URL` (auto, généré par `random_password`). Injectés via `value_source.secret_key_ref`. |
| **Observabilité — BigQuery** | LiteLLM `success_callback: ["bigquery"]`. Dataset `var.bigquery_dataset` (défaut : `litellm_observability`). Table `litellm_logs` avec schéma Terraform explicite (colonnes : `request_id`, `model`, `input_tokens`, `output_tokens`, `total_tokens`, `spend`, `response_ms`, `user`, `key_alias`, `team`, `created_at`). |
| **Observabilité — Cloud Monitoring** | `google_logging_metric` pour : (1) input_tokens, (2) output_tokens, (3) cost (spend), (4) latence (response_ms). `google_monitoring_dashboard` avec 4 graphiques : tokens lus/écrits (counters), coût cumulé (sum), latence P50/P99 (distribution). |
| **IAM BigQuery** | Runner SA : `roles/bigquery.dataEditor` sur le dataset + `roles/bigquery.jobUser` sur le projet. |
| **Env vars observabilité** | Cloud Run : `BIGQUERY_DATASET` (valeur de `var.bigquery_dataset`), `BIGQUERY_PROJECT` (valeur de `var.project_id`). |

#### 📝 Contraintes de Code

1. **Cloud SQL** : Module `terraform-google-modules/sql-db/google//modules/postgresql ~> 22.0`. IP privée uniquement (`ipv4_enabled = false`). Flag `cloudsql.iam_authentication = on`.
2. **Cloud SQL Auth Proxy** : Sidecar `containers[1]`, image `gcr.io/cloud-sql-connectors/cloud-sql-proxy:2`. Args : `["--structured-logs", "--port=5432", "<INSTANCE_CONNECTION_NAME>"]`. Startup probe TCP sur port 5432. LiteLLM `depends_on = ["cloud-sql-proxy"]`.
3. **DATABASE_URL** : `postgresql://litellm:<PASSWORD>@localhost:5432/litellm`. Généré par `random_password`, stocké automatiquement dans Secret Manager.
4. **config.yaml (LiteLLM)** : Activer `success_callback: ["bigquery"]` dans `litellm_settings`. Ajouter `database_url: os.environ/DATABASE_URL` + `store_model_in_db: false` dans `general_settings`. **8 modèles** avec les régions correctes : `eu` pour Gemini+Claude, `europe-west4` pour Gemma. IDs Claude sans `@date`. IDs Gemma : `vertex_ai/google/gemma3@gemma-3-{size}-it`. Si Gemma serverless non disponible : deployer via Model Garden et utiliser `vertex_ai/<ENDPOINT_ID>` + `api_base`.
5. **BigQuery table** : Créer via `google_bigquery_table` avec schéma JSON explicite dans `bigquery.tf`. `deletion_protection = false` en dev.
6. **Log-based metrics** : Filtre `resource.type="cloud_run_revision" AND jsonPayload.model!="" AND jsonPayload.usage.prompt_tokens > 0`. Extraire les valeurs numériques via `valueExtractor` sur `jsonPayload.usage.prompt_tokens` etc.
7. **Dashboard** : Créer via `google_monitoring_dashboard` avec `dashboard_json` (JSON inline ou `templatefile`). 4 widgets minimum : input_tokens, output_tokens, spend, latence.
8. **DNS** : `var.dns_name` configurable. Si vide, pas de ressources DNS.
9. **Idempotence** : Tous les `task` doivent être idempotents (`|| true` sur les creates, `terraform apply --auto-approve`).
10. **Labels** : `default_labels.project = "gcp-samples_cloudrun-litellm-proxy"` (underscores, pas de slashes).

#### 🗒️ Notes & Améliorations différées
- [ ] **Redis** : Memorystore pour cache partagé cross-instances et rate-limit counters (~35 EUR/mois).
- [ ] **Looker Studio** : Connecter le dataset BigQuery à un dashboard Looker Studio pour les analyses par utilisateur/modèle.
- [ ] **Alertes** : `google_monitoring_alert_policy` sur dépassement de budget par key ou pic de coût.
- [ ] **Multi-Région** : Paramétrer `var.region` pour d'autres régions Vertex-compatibles.
- [ ] **CI/CD** : Pipeline GitHub Actions pour build + `task apply` sur merge.
