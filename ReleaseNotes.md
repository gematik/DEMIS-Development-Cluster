<img align="right" alt="gematik" width="250" height="47" src="media/Gematik_Logo_Flag.png"/> <br/>    

# Release Notes DEMIS Kubernetes Environment

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
