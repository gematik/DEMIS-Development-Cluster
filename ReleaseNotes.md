<img align="right" alt="gematik" width="250" height="47" src="media/Gematik_Logo_Flag.png"/> <br/>    

# Release Notes DEMIS Kubernetes Environment

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
