<img align="right" alt="gematik" width="250" height="47" src="media/Gematik_Logo_Flag.png"/> <br/>    

# Release Notes DEMIS Kubernetes Environment

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
