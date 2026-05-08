# Todo list


## Gce-g2-gpu-instance

J'ai copié le sample "gce-g2-gpu-instance", fait une review, think et met le au standard du projet.

Il doit être intégré et respecter les mêmes standards que les autres samples.



## GKE Sample - application

J'ai besoin d'une application dans le dossier gke-base-sample/application.

C'est une application qui expose un sample web service REST.
L'application est structuré pour répondre au critère d'exigences de l'architecture hexagonale ou clean architecture.
L'api health actuator est activé.

Respecte les best practices java 25 et spring boot 4

Le projet maven doit être multi modulaire avec un parent et les modules enfants.

sample java:
- java25
- spring boot
- maven
- tests:
 - unitaire (bdd local h2)
 - integration (bdd container podman postgres)
- image docker java (souche docker hdi java si possible)

Dépendances obligatoires:
- Spring Web WEB
- Spring Data JPA SQL
- Spring Security SECURITY
- PostgreSQL Driver SQL
- Google Cloud Support GOOGLE CLOUD
- Google Cloud Messaging GOOGLE CLOUD
- Google Cloud Storage GOOGLE CLOUD
- Spring Boot Actuator

Orchestrer toute la CI build dans le taskfile.
