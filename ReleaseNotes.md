<img align="right" alt="gematik" width="250" height="47" src="media/Gematik_Logo_Flag.png"/> <br/>    

# Release Notes DEMIS Kubernetes Environment

## Release 5.3.1
- reverted removed ff NEW_API_ENDPOINTS for portal-igs

## Release 5.3.0
- removed ff NEW_API_ENDPOINTS for portal-igs
- fixed prometheus scraping for local cluster
- added rabbitmq url for secure-message-gateway
- added spring profiles config for ars-service
- added new deployment strategy "rolling" to deploy i.a. stateful sets without downtime
- added RabbitMq secret to demis namespace
- fix apt-key command in install-tools.sh
- deploy dmz before services
- remove profile for ars-service
- added rabbitmq user password hash
- changed/fixed refresh rancher api token pipeline for fkb location
- added new helm values for istio-ingressgateway
- moved Pipeline to other project
- added environment variable for code mapping client addresses to futs and lifecycle-validation-service
- fix typos in validation-service-charts
- update pipelines/targets of dmz-dev, dmz-qs, dmz-prod-test for test-stages
- fix mesh secret handling

## Release 5.2.0
- fixed pipeline for infrastructure rollout for correct defining of GOOGLE_APPLICATION_CREDENTIALS
- added postgres and pgbouncer to dmz namespace
- added database-configurations for bulk
- set headers x-fhir-profile, x-fhir-api-version, x-fhir-api-request-origin, x-fhir-api-submission-type in istio-values.yaml of notification-gateway and notification-processing-service
- modularized http timeouts and retries for all services
- added hmac secret variable for ars bulk service
- made bulk-inbound-service reachable for bulk and upload
- Remove unnecessary IGS-variable storage_tls_certificate
- added environment variables to dmz/bulk-inbound-service
- added waf and secure-message-gateway to dmz namespace 
- adjusted paths for ARS bulk upload to current specification
- set timeout for minio to 5 min for local cluster

## Release 5.1.0
- bulk-inbound-service reachable from ingres
- added functionality of kubeconfig usage for terraform on kkp stages
- edit depends_on to futs for gateway igs
- fixed package-registry url for validation-services and futs services
- added make target for ref-fkb and prod-fkb
- fixed kiali configuration for connecting to istio resources

## Release 5.0.0
- added new policies: kubernetes-network-policies for all application namespaces
- upgraded providers
  - hashicorp/helm version to 3.1.1
  - hashicorp/kubernetes version to 3.0.1
- refactored jaeger deployment
- fixed naming errors and enforce lint conventions
- added flag for enabling istio native sidecar usage (default false)
- increased default memory limit for istio proxy to 256Mi

## Release 4.4.1
- fixed DMZ terraform backend activation
- fixed ignoring config options with null value
- fixed 'all' keyword for feature flags and configs
- fixed Jaeger Resource requests and limits 
- added fhir-profiles-metadata module for services futs-core and futs-igs
- added validation for services are allowed to define profiles in active versions file
- modified deployment order. Now services validation-service-core, validation-service-igs, validation-service-ars, futs-core and futs-igs depends on package-registry.

## Release 4.4.0
- added ARE modul (EKM3)
- added DMZ modul
- added destination-lookup-service urls to NPS, NRS and LVS
- fix gitlab urls in scripts
- removed truststore-certs-secrets for keycloak
- add resource requests and limits for istio proxy sidecars
- added prometheus jobs for rabbitmq and improved for services in local

## Release 4.3.3
- fix namespace name for new testenvironment 

## Release 4.3.2
- fix istio metrics path for metric scraping

## Release 4.3.1
- fix default db for ref environment in switch database script

## Release 4.3.0
- added truststore-certs-secrets for keycloak
- Fix new API endpoints routing for portal pathogen and disease to futs
- added tsl-download endpoint
- added support of FHIR packages
- add grafana metrics annotations for istiod
- add meldungs domain for mesh network policies

## Release 4.2.1
- truncate checksums

## Release 4.2.0
- refactor module fhir-profiles-metadata for better profile update handling on non-canary deployment of validation services (requires service version 2.9.1)
- Add additional test-configuration for prod-test environment
- cron jobs will be only manually triggered if references services or own service will be updated
- adding coding standards to CONTRIBUTING.md

## Release 4.1.0
- added versioned s3-controller urls for igs
- receiving sequence data for outdated api version supported
- removed Test User IDs from Notification Processing Service Template
- add scale down and scale up make targets for all demis deployments
- add secretKeyRef for ars-pseudo-purger
- fix traffic weight for non-canary deployments
- adjust tests for modules helm_deployment and flags
- environment variable added to surveillance-pseudonym-service-ars
- removed ars-pseudonymization-service 
- add new cronjob surveillance-pseudonym-purger-ars
- add starting dependency for keycloak to local idp
- add checksums to all secrets
- add secret checksums to all helm charts from all services that use these secrets
- split file chart-destination-lookup.tf in files chart-destination-lookup-writer.tf, chart-destination-lookup-reader.tf and chart-destination-lookup-purger.tf
- added sidecar tsl-deliverer-mock for keycloak. Needed only for local and dev deployment
- changed redis ACL for the reader and writer accounts

## Release 4.0.0
#### Breaking:
- upgrade required terraform version to 1.9.0
- upgrade provider hashicorp/helm to 3.0.2
- for local development KIND version 0.30.0 is required
- update apt package manager resource for helm (old is unavailable)
#### improvements and features:
- add db entries for pgbouncer only if necessary
- determine postgres initialization config from running services
- updating kyverno
- fix grafana dashboard download issue on empty folder in terraform
- upgrade provider hashicorp/kubernetes to 2.38.0
- update custom dashboards
- add more documentation for customizing new EKM deployment modules
- add destination lookup services to switch database script

## Release 3.8.1
- Update structure of the service account Kubernetes secret.
- add database for destination-lookup to pgbouncer and postgres
- remove unused variables from ekm-template
- add resource for destination-lookup-service
- make stage-configuration-data optional
- remove unused secret for gematik-idp
- changed routing of requests to FUTS
- added profile version for IGS in Gateway-IGS

## Release 3.8.0
- add module fhir-profiles-metadata v2
- add setup for provisioning modes dedicated, distributed and combined on validation services
- add setup for versioned profile snapshots and external access on validation services, ars-service, igs-service, report-processing-service and notification-processing-service
- add Support for new API Endpoint for Backend-Services
- new API Endpoint change for FFS Reader Search url
- add new API endpoints for portal-bedoccupancy
- add new API endpoints for portal-pathogen
- add new API endpoints for HLS
- add new API endpoints for NG
- add new API endpoints for RPS
- add new API endpoints for policies-authorizations
- add new API endpoints for portal-disease
- add new API endpoints for notification-gateway
- add new API endpoints for portal-shell
- add new API endpoints for portal-igs
- new API endpoint use profile header x-fhir-profile instead of fhirProfile
- make TF_EXTRA_ARGS environment variable available for passing parameters from command line to opentofu
- ARS: use surveillance-pseudonym-service-ars instead of ars-pseudonymization-service   
- ARS: add secret ars-pseudo-hash-pepper to demis environment
- surveillance-pseudonym-service-ars: app-values extended 
- add support for using Kubernetes secrets to provide GCP service account key files.
- add ekm-template

## Release 3.7.2
- skip manual job creation if job is suspended (CUS, FSP, KUP)
- add surveillance-pseudonym database to pgbouncer

## Release 3.7.1
- remove NCAPI mirror

## Release 3.7.0
- Add new service: surveillance-pseudonym-service-ars
- Remove external virtual service from package-registry
- remove NCAPI and pseudo-storage database from pgbouncer and postgres
- Update switch Database Script

## Release 3.6.0
- Remove deprecated Pseudonymization-Storage-Service
- use last version of activated gcp secrets for deployments
- Remove NCAPI References + API Key
- Add Filter to exclude option values with null values
- Added new service: Package Registry
- Add ABC Prod Fra
- Remove external virtual service from ars-pseudonymization-service

## Release 3.5.0
- Remove keycloak-gematik-idp-public-key as variable and add as config option.

## Release 3.4.3
- Remove keycloak-gematik-idp-public-key as variable and add as config option.
- Terminology server FHIR snapshot configuration change to apply all validation services' snapshots
- Update Database Pipeline for abc Cluster
- Added default addresses for 'ars-service'

## Release 3.4.2
- Update gitignore
 
## Release 3.4.1
- Update Readme with new disclaimer

## Release 3.4.0
- Update Jenkins Pipelines for publishing to GitHub 
- Update Jenkins Pipelines for automatic validation 

## Release 3.3.0
- Add functionality defining alternative fhir-profile-snapshot version for futs
- fix null update for profiles in canary to main transition on active-versions.yaml

## Release 3.2.0
- Add charts for new service 'ars-pseudonymization-service'
- Add charts for new service 'terminology-server'
- Add functionality defining multiple profiles for validation services

## Release 3.1.0
- Add new secret for keycloak token exchange
- Add new secret for certificate-update-service

## Release 3.0.0
- Helm Chart Template Values are now part of theis repository
- Resources and Replicas can be fully customised over a variable
- Added new Makefile targets for linting, docs, formatting

## Release 2.0.0
- New Project Structure, centralization of identity management services in own namespace
- Minor bugfixes

## Release 1.3.0
- First official GitHub-Release
