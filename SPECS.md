# SPECS - Changelog & Décisions

Ce fichier trace l'historique des choix d'architecture, des spécifications et des synthèses techniques par date.

---

## [2026-04-07] - Daily Log - Création VPC, Bastion Cloud Run, dépôts Artifact Registry, configuration Task/Terraform, optimisation du log quotidien et sécurisation dynamique de l'agent

### Décisions et Spécifications
- **Topologie du VPC** : Utilisation du module officiel Terraform GCP pour provisionner un sous-réseau public et deux privés en fermant l'accès inter-privé par défaut (`europe-west9`).
- **Architecture Cloud Run Bastion** : Proxy SOCKS5 protégé via IAP, `INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER` et accès privé BDD géré par `Direct VPC Egress` et `Private Services Access`.
- **Artifact Registry** : Provisionnement de deux dépôts Docker (`cloudrun-simple-job` & `cloudrun-simple-service`) avec Container Vulnerability Scanning activé par défaut.
- **Task & Terraform** : Prise en charge conditionnelle des variables (`terraform.tfvars`) intégrée de façon transparente dans les configurations `Taskfile.yml`.
- **Suivi des Spécifications** : Mise à jour de `AGENTS.md` pour imposer un format "Daily Log" regroupé sous un seul titre synthétique par jour dans `SPECS.md`.
- **Bugfix Cloud Run** : Suppression de l'attribut non supporté `deletion_protection` sur les ressources Cloud Run (`google_cloud_run_v2_job` et `google_cloud_run_v2_service`) suite à une incompatibilité avec la version minimale du provider `google`.
- **Sécurisation de l'Agent** : Création de la règle `security.md` fixant un verrouillage d'exécution de commande au répertoire projet actif (scope lock) et des best practices de prompting pour une sécurité dynamique (vérification du contexte plutôt que blocage statique au root).
- **Bugfix Pre-commit** : Correction des arguments du hook `terraform_docs` (`--path-to-file=../TFDOCS.md` et `--create-file-if-not-exist=true`) dans le skill Terraform et les configurations de chaque projet pour que le fichier de documentation soit correctement généré à la racine de chaque composant (ex: `samples/base/TFDOCS.md`).
- **Standardisation de la Documentation** : Création du skill `The Documentalist` regroupant les conventions de documentation Markdown et exigence d'insérer un lien vers l'auto-documentation Terraform formatté (`> [📚 Consulter la documentation Terraform auto-générée (TFDOCS.md)](./TFDOCS.md)`) en tête de tous les READMEs de samples.
- **Refonte Modulaire des Agents** : Création d'un Master Prompt (Morpheus) et division des comportements métiers en règles strictes (Pre-commit, Taskfile, Terraform) pour une meilleure priorisation par l'IA.
