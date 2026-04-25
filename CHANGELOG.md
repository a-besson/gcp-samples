
# SPECS - Changelog & Décisions

Ce fichier trace l'historique des choix d'architecture, des spécifications et des synthèses techniques par date.

---


## [2026-04-25] - Daily Log - Résolution des erreurs de déploiement GKE et mise en conformité pre-commit (YAML multi-doc, TFLint).
- **Résolution des erreurs de déploiement GKE** : correction du nom du cluster dans Taskfile et ajout de l'IP locale aux authorized networks.
- **Conformité pre-commit** : mise à jour du hook `check-yaml` pour supporter les manifests multi-documents et suppression des déclarations Terraform inutilisées dans `iam.tf`.

## [2026-04-19] - Daily Log - Création du sample GKE Autopilot privé avec service Nginx interne (ILB), NetworkPolicy, sécurité pod renforcée et accès kubectl sécurisé via IAP/Master Authorized Networks.

### Décisions et Spécifications
- **GKE Autopilot Private Cluster** : Déploiement via le module officiel `terraform-google-modules/kubernetes-engine//modules/beta-autopilot-private-cluster` (~v36.0). Cluster régional sur `subnet-priv-a` avec private nodes, pas d'IP publique sur les nœuds, control plane protégé par Master Authorized Networks (subnet-priv-a + plage IAP 35.235.240.0/20).
- **Réseau** : Réutilisation de l'infrastructure base via `terraform_remote_state`. Pods alloués sur la plage secondaire existante `secondary-range` (100.64.0.0/22). Services auto-alloués par GKE. Control plane isolé sur 172.16.0.0/28.
- **Nginx Internal Load Balancer** : Service Kubernetes de type `LoadBalancer` avec annotation `cloud.google.com/load-balancer-type: "Internal"`. L'IP privée est attribuée sur le subnet-priv-a, rendant le service inaccessible depuis le subnet-public et internet.
- **NetworkPolicy** : Politique réseau restrictive limitant l'ingress nginx aux plages privées RFC 1918 (10.0.0.0/8) et RFC 6598 (100.64.0.0/10) uniquement.
- **Sécurité Pod (Best Practices K8s)** : Image `nginxinc/nginx-unprivileged:1.27-alpine` (non-root UID 101), `readOnlyRootFilesystem`, profil `seccompProfile: RuntimeDefault`, `capabilities: drop ALL`, `automountServiceAccountToken: false`, resource requests/limits explicites.
- **Accès kubectl sécurisé** : Deux méthodes documentées — (1) via IAP tunnel depuis une VM du subnet privé, (2) via réseau autorisé si l'IP source est whitelistée. Master global access activé pour permettre l'accès cross-region.
- **Orchestration** : Taskfile v3 avec tâches `get-credentials`, `deploy-nginx`, `test-nginx`, `port-forward`, `undeploy-nginx` en complément du cycle Terraform standard (init/plan/apply/destroy).
- **Tests IaC** : Tests plan-level validant le nommage du cluster, l'activation des APIs et la résolution des références réseau de la base.

---

## [2026-04-09] - Daily Log - Industrialisation du cycle de vie GCP : centralisation Artifact Registry, récupération DNS (Cloud Endpoints), fiabilisation Podman, et correction du cycle de destruction (Direct VPC Egress IP cleanup latency).


### Décisions et Spécifications
- **Centralisation des Registres (Standard Industriel)** : Migration de tous les dépôts Artifact Registry vers la pile foundational `base`. Cette décision élimine les conditions de course (Race Conditions) et les erreurs `409 Conflict` / `404 Not Found` en garantissant l'existence des dépôts avant tout build applicatif.
- **Résilience DNS (Cloud Endpoints)** : Implémentation d'une tâche automatisée `undelete-dns` utilisant `gcloud endpoints services undelete`. Cette automatisation permet de contourner le verrou de 30 jours appliqué par GCP sur les services Endpoints supprimés, rendant le cycle de vie `destroy/apply` totalement idempotent.
- **Résilience du Cycle de Destruction (Direct VPC Egress)** : Intégration d'une tâche d'attente déterministe `wait-for-serverless-cleanup` dans l'orchestrateur Task. Cette mesure pallie la latence de libération des IPs éphémères par GCP (`serverless-ipv4-*`), garantissant le succès de la suppression des sous-réseaux lors d'un `task destroy-all`.
- **Pattern de Destruction Delay (Industrial Standard)** : Intégration d'un provisionneur `local-exec` effectuant un `sleep 60` lors de la destruction des instances Cloud SQL. Cette mesure de résilience garantit que GCP libère les routes de peering VPC avant que Terraform ne tente de supprimer la connexion `servicenetworking`, résolvant ainsi l'erreur structurelle `Producer services are still using this connection` (Error 9).
- **Synchronisation du Nommage** : Généralisation de l'injection dynamique du suffixe d'environnement (`NAME_SUFFIX`) dans les variables `REPO_NAME` des Taskfiles. Alignement strict entre le nommage de l'infrastructure provisionnée et les cibles de l'orchestrateur de build.
- **Découplage Build/Infra** : Suppression définitive des provisionneurs Terraform (`null_resource`) au sein des samples. La responsabilité de la construction et de la poussée des images est désormais déléguée exclusivement à l'orchestrateur Task, assurant une séparation propre des préoccupations.
- **Refactorisation de la stack Bastion** : Transformation du bastion en composant purement applicatif consommant les registres centraux via les `remote_state` de la pile `base`.
- **Fiabilisation de l'Authentification Container** : Standardisation de la connexion Podman via l'injection directe de jetons d'accès (`gcloud auth print-access-token`), résolvant les blocages intermittents constatés sur macOS avec les helpers de certificats natifs.

---

## [2026-04-08] - Daily Log - Migration vers le Cloud SQL Auth Proxy (Standard Industriel), modernisation du Bastion (Debian Slim + Tinyproxy), suppression des composants legacy SOCKS5 et fiabilisation du Direct VPC Egress.

### Décisions et Spécifications
- **Standardisation Toolchain (Podman)** : Alignement complet du cycle de vie local sur Podman (build + run) pour éviter les désynchronisations d'images constatées entre Docker et Podman sur les workstations hybrides.
- **Isolation de Service (Tinyproxy User)** : Création d'un utilisateur système `tinyproxy` dédié dans le conteneur. Cette approche industrielle résout les conflits de nom de groupe (`nobody` vs `nogroup`) entre distributions et renforce la sécurité par le principe du moindre privilège.
- **Orchestration Globale (Standard Industriel)** : Migration du modèle `includes` (limité par `go-task`) vers une orchestration par appel de répertoires (`task --directory`). Ce design permet aux samples de rester 100% autonomes avec leur propre chargement de `.env`, tout en permettant un pilotage centralisé (`apply-all`, `destroy-all`) robuste et parallélisé.
- **Standardisation de la Connectivité SQL (Auth Proxy)** : Abandon du tunneling complexe SOCKS-over-IAP au profit du **Cloud SQL Auth Proxy**. Cette solution offre une sécurité native basée sur l'IAM et des performances optimales via une connexion directe chiffrée.
- **Activation de l'interface Public IP (Secured)** : Activation contrôlée de `ipv4_enabled` sur l'instance Cloud SQL pour permettre l'accès au proxy depuis l'extérieur du VPC (sans VPN). La sécurité est garantie par l'absence de réseaux autorisés et l'exigence de certificats SSL/IAM gérés par le proxy.
- **Modernisation du Container Bastion (Debian Slim)** : Migration de l'image de base d'Alpine vers `debian:bookworm-slim` pour une meilleure stabilité industrielle. Passage définitif à **Tinyproxy** (HTTP Proxy) pour assurer la compatibilité protocolaire avec IAP/GCLB via la méthode `HTTP CONNECT`.
- **Nettoyage Legacy** : Suppression du serveur **Dante SOCKS5**, de sa configuration (`sockd.conf`) et des outils de bridge intermédiaires devenus obsolètes (`socat` côté container).
- **Industrialisation Taskfile** : Intégration de la tâche `task db-proxy` pour automatiser le cycle de vie du tunnel local et mise à jour des tests de connectivité HTTP.
- **Robustesse Direct VPC Egress** : Forçage des références de sous-réseau via les IDs complets Terraform pour garantir une résolution réseau déterministe.

## [2026-04-07] - Daily Log - Industrialisation de l'IA, orchestration Task, VPC Secondary Ranges, Network Tests VMs, Artifact Registry, tests unitaires Terraform, standardisation Documentation et mise à jour Cloud Run Authentifié (Port 443, SSL/DNS par défaut) avec tests REST automated.

### Décisions et Spécifications
- **Topologie du VPC** : Utilisation du module officiel Terraform GCP pour provisionner un sous-réseau public et deux privés en fermant l'accès inter-privé par défaut (`europe-west9`).
- **Tests de Connectivité Réseau** : Provisionnement de trois VM de test (`e2-micro`) : `vm-test-a`, `vm-test-b` et `vm-test-public`. Accès shell sécurisé via **IAP** et **OS Login**.
- **Gestion des Labels, Tags et Firewall** : Harmonisation de l'infrastructure (`VPC module v16.0`, `Provider v6.0`). Ajout explicite du label `env=dev` et du network tag `dev` sur toutes les VMs. Refonte des règles de pare-feu (gérées historiquement comme des `google_compute_firewall` distincts) via le module officiel `terraform-google-modules/network/google//modules/firewall-rules` pour renforcer la standardisation et restreindre les flux aux environnements taggués.
- **Ranges IP Secondaires** : Ajout d'une plage IP secondaire (`secondary-range`) sur les subnets privés `A` et `B` utilisant le bloc d'adressage RFC 6598 (`100.64.0.0/22` et `100.64.4.0/22`) pour supporter les charges de travail natives Cloud (GKE, Cloud Run via VPC Connector).
- **Industrialisation de l'IA** : Migration du Master Prompt Morpheus vers une architecture modulaire de compétences (`skills/morpheus-expert-devops`), isolation des standards de base dans `rules/common.md` et définition d'une priorité P0 absolue pour le framework Morpheus.
- **Orchestration & Dépendances** : Automatisation du setup via `task init` incluant l'installation idempotente des dépendances système (Homebrew) et la gestion du cycle de vie des skills (installation, mise à jour, nettoyage des dossiers parasites).
- **Correctif Réseau** : Résolution des erreurs de provisionnement VPC dans `samples/base` en ajustant les masques CIDR de `/20` à `/22` pour respecter les frontières d'adressage valides (alignement sur `10.0.4.0` et `10.0.20.0`).
- **Standardisation Visuelle** : Mise à jour du skill `The Documentalist` pour intégrer les sources d'icônes GCP officielles (gcpicons.com, Draw.io, Icons8) et utilisation systématique de logos dynamiques pour les en-têtes de documentation.
- **Architecture Cloud Run Bastion** : Proxy SOCKS5 protégé via IAP, `INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER` et accès privé BDD géré par `Direct VPC Egress` et `Private Services Access`.
- **Artifact Registry** : Provisionnement de deux dépôts Docker (`cloudrun-simple-job` & `cloudrun-simple-service`) avec Container Vulnerability Scanning activé par défaut.
- **Task & Terraform** : Prise en charge conditionnelle des variables (`.env` avec préfixes `TF_VAR_`) intégrée de façon transparente dans les configurations `Taskfile.yml`.
- **Suivi des Spécifications** : Mise à jour de `AGENTS.md` pour imposer un format "Daily Log" regroupé sous un seul titre synthétique par jour dans `SPECS.md`.
- **Bugfix Cloud Run** : Suppression de l'attribut non supporté `deletion_protection` sur les ressources Cloud Run (`google_cloud_run_v2_job` et `google_cloud_run_v2_service`) suite à une incompatibilité avec la version minimale du provider `google`.
- **Sécurisation de l'Agent** : Création de la règle `security.md` fixant un verrouillage d'exécution de commande au répertoire projet actif (scope lock) et des best practices de prompting pour une sécurité dynamique (vérification du contexte plutôt que blocage statique au root).
- **Bugfix Pre-commit** : Correction des arguments du hook `terraform_docs` (`--path-to-file=../TFDOCS.md` et `--create-file-if-not-exist=true`) dans le skill Terraform et les configurations de chaque projet pour que le fichier de documentation soit correctement généré à la racine de chaque composant (ex: `samples/base/TFDOCS.md`).
- **Standardisation de la Documentation** : Création du skill `The Documentalist` regroupant les conventions de documentation Markdown et exigence d'insérer un lien vers l'auto-documentation Terraform formatté (`> [📚 Consulter la documentation Terraform auto-générée (TFDOCS.md)](./TFDOCS.md)`) en tête de tous les READMEs de samples.
- **Tests Unitaires IaC** : Implémentation du framework `terraform test` dans le module `base/infra` avec validation des plans et des 'apply' (VPC, subnets, services API), intégration de la gestion dynamique des variables (`.env`) via `task test`.
- **Migration Cloud Run Authentifié** : Mise à jour du composant `cloudrun-simple-service` pour supporter l'écoute native sur le port **443** (container port), exposition via les certificats et l'adressage DNS Google par défaut (`INGRESS_TRAFFIC_ALL`) et verrouillage strict par IAM (`allAuthenticatedUsers`).
- **Validation REST Automated** : Intégration de tests de bout en bout (E2E) via `terraform test` effectuant des appels REST authentifiés (Identity Token) pour valider la disponibilité et la sécurité du service post-déploiement.
- **Architecture Cloud Run LB + IAP** : Exposition de Cloud Run derrière un Load Balancer (GCLB) avec **Serverless NEG**, sécurisation par **IAP** (Identity-Aware Proxy) et utilisation de **Cloud Endpoints DNS** pour obtenir un domaine `.cloud.goog` gratuit avec certificat SSL managé.
- **Standardisation des Schémas** : Adoption du format **Draw.io** (XML) pour les schémas d'architecture technique intégrés aux samples, permettant une édition directe et un versionnage Git (ex: `architecture.drawio`).
- **Orchestration & Debug Local (Bastion)** : Ajout de tâches `task build`, `task bastion-run` et `task test-local` pour valider l'image Docker et le fonctionnement du proxy SOCKS5 en local avant déploiement.
- **Bootstrapping Industriel** : Implémentation de la tâche `task setup` pour automatiser la création des ressources critiques amont (Bucket GCS pour le state Terraform, Artifact Registry pour les images) de manière idempotente.
- **Debug Base de Données Privée** : Introduction de **psql via SOCKS5 library (`libpq`)** dans les procédures de diagnostic, permettant une inspection directe des bases Cloud SQL privées à travers le bastion Cloud Run via `ALL_PROXY`.
- **Compatibilité Multi-Architecture** : Forçage du build Docker en `linux/amd64` pour assurer la portabilité native sur Google Cloud Run, évitant les échecs de démarrage liés à l'architecture processeur (ex: build Apple Silicon vs runtime Cloud Run).
- **Gestion des Contraintes IAP** : Documentation de la contrainte "Single Brand per Project" pour `google_iap_brand` et mise en place de guides de dépannage pour les projets avec écrans OAuth pré-existants.
