# applications

Module responsible for deploying the DEMIS Services Helm Charts in a Kubernetes Cluster.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.17.0, < 3.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ars_service"></a> [ars\_service](#module\_ars\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_context_enrichment_service"></a> [context\_enrichment\_service](#module\_context\_enrichment\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_fhir_storage_purger"></a> [fhir\_storage\_purger](#module\_fhir\_storage\_purger) | ../../modules/helm_deployment | n/a |
| <a name="module_fhir_storage_reader"></a> [fhir\_storage\_reader](#module\_fhir\_storage\_reader) | ../../modules/helm_deployment | n/a |
| <a name="module_fhir_storage_writer"></a> [fhir\_storage\_writer](#module\_fhir\_storage\_writer) | ../../modules/helm_deployment | n/a |
| <a name="module_futs_core"></a> [futs\_core](#module\_futs\_core) | ../../modules/helm_deployment | n/a |
| <a name="module_futs_igs"></a> [futs\_igs](#module\_futs\_igs) | ../../modules/helm_deployment | n/a |
| <a name="module_gateway_igs"></a> [gateway\_igs](#module\_gateway\_igs) | ../../modules/helm_deployment | n/a |
| <a name="module_hospital_location_service"></a> [hospital\_location\_service](#module\_hospital\_location\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_igs_service"></a> [igs\_service](#module\_igs\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_lifecycle_validation_service"></a> [lifecycle\_validation\_service](#module\_lifecycle\_validation\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_minio"></a> [minio](#module\_minio) | ../../modules/helm_deployment | n/a |
| <a name="module_notification_clearing_api"></a> [notification\_clearing\_api](#module\_notification\_clearing\_api) | ../../modules/helm_deployment | n/a |
| <a name="module_notification_gateway"></a> [notification\_gateway](#module\_notification\_gateway) | ../../modules/helm_deployment | n/a |
| <a name="module_notification_processing_service"></a> [notification\_processing\_service](#module\_notification\_processing\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_notification_routing_service"></a> [notification\_routing\_service](#module\_notification\_routing\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_pdfgen_service"></a> [pdfgen\_service](#module\_pdfgen\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_pgbouncer"></a> [pgbouncer](#module\_pgbouncer) | ../../modules/helm_deployment | n/a |
| <a name="module_portal_bedoccupancy"></a> [portal\_bedoccupancy](#module\_portal\_bedoccupancy) | ../../modules/helm_deployment | n/a |
| <a name="module_portal_disease"></a> [portal\_disease](#module\_portal\_disease) | ../../modules/helm_deployment | n/a |
| <a name="module_portal_igs"></a> [portal\_igs](#module\_portal\_igs) | ../../modules/helm_deployment | n/a |
| <a name="module_portal_pathogen"></a> [portal\_pathogen](#module\_portal\_pathogen) | ../../modules/helm_deployment | n/a |
| <a name="module_portal_shell"></a> [portal\_shell](#module\_portal\_shell) | ../../modules/helm_deployment | n/a |
| <a name="module_postgres"></a> [postgres](#module\_postgres) | ../../modules/helm_deployment | n/a |
| <a name="module_pseudonymization_service"></a> [pseudonymization\_service](#module\_pseudonymization\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_pseudonymization_storage_service"></a> [pseudonymization\_storage\_service](#module\_pseudonymization\_storage\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_report_processing_service"></a> [report\_processing\_service](#module\_report\_processing\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_validation_service_ars"></a> [validation\_service\_ars](#module\_validation\_service\_ars) | ../../modules/helm_deployment | n/a |
| <a name="module_validation_service_core"></a> [validation\_service\_core](#module\_validation\_service\_core) | ../../modules/helm_deployment | n/a |
| <a name="module_validation_service_igs"></a> [validation\_service\_igs](#module\_validation\_service\_igs) | ../../modules/helm_deployment | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.futs](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.validation_service](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ars_profile_snapshots"></a> [ars\_profile\_snapshots](#input\_ars\_profile\_snapshots) | Defines the FHIR Profile Version for ARS to be used in the DEMIS Environment | `string` | n/a | yes |
| <a name="input_auth_hostname"></a> [auth\_hostname](#input\_auth\_hostname) | The Keycloak Issuer URL to be used for the JSON Web Token (JWT) validation | `string` | `"auth"` | no |
| <a name="input_cluster_gateway"></a> [cluster\_gateway](#input\_cluster\_gateway) | Defines the Istio Cluster Gateway to be used | `string` | `"mesh/demis-core-gateway"` | no |
| <a name="input_config_options"></a> [config\_options](#input\_config\_options) | Defines a list of ops flags to be bound in services | `map(map(string))` | `{}` | no |
| <a name="input_context_path"></a> [context\_path](#input\_context\_path) | The context path for reaching the DEMIS Services externally | `string` | `""` | no |
| <a name="input_core_hostname"></a> [core\_hostname](#input\_core\_hostname) | The URL to access the DEMIS Core API | `string` | `""` | no |
| <a name="input_database_target_host"></a> [database\_target\_host](#input\_database\_target\_host) | Defines the Hostname of the Database Server | `string` | n/a | yes |
| <a name="input_debug_enabled"></a> [debug\_enabled](#input\_debug\_enabled) | Defines if the backend Java Services must be started in Debug Mode | `bool` | `false` | no |
| <a name="input_deployment_information"></a> [deployment\_information](#input\_deployment\_information) | Structure holding deployment information for the Helm Charts | <pre>map(object({<br/>    chart-name          = optional(string) # Optional, uses a different Helm Chart name than the application name<br/>    image-tag           = optional(string) # Optional, uses a different image tag for the deployment<br/>    deployment-strategy = string<br/>    enabled             = bool<br/>    main = object({<br/>      version = string<br/>      weight  = number<br/>    })<br/>    canary = optional(object({<br/>      version = optional(string)<br/>      weight  = optional(string)<br/>    }), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | The docker registry to use for the application | `string` | n/a | yes |
| <a name="input_external_chart_path"></a> [external\_chart\_path](#input\_external\_chart\_path) | The path to the stage-dependent Helm Chart Values. | `string` | n/a | yes |
| <a name="input_feature_flags"></a> [feature\_flags](#input\_feature\_flags) | Defines a list of feature flags to be bound in services | `map(map(bool))` | `{}` | no |
| <a name="input_fhir_profile_snapshots"></a> [fhir\_profile\_snapshots](#input\_fhir\_profile\_snapshots) | Defines the FHIR Profile Version to be used in the DEMIS Environment | `string` | n/a | yes |
| <a name="input_fhir_storage_purger_cron_schedule"></a> [fhir\_storage\_purger\_cron\_schedule](#input\_fhir\_storage\_purger\_cron\_schedule) | Defines the Cron Schedule for the FHIR storage purger | `string` | n/a | yes |
| <a name="input_fhir_storage_purger_suspend"></a> [fhir\_storage\_purger\_suspend](#input\_fhir\_storage\_purger\_suspend) | Defines if the fhir-storage-purger is suspended. | `bool` | `false` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | The helm repository to use for the application | `string` | n/a | yes |
| <a name="input_helm_repository_password"></a> [helm\_repository\_password](#input\_helm\_repository\_password) | The password for the helm repository | `string` | `""` | no |
| <a name="input_helm_repository_username"></a> [helm\_repository\_username](#input\_helm\_repository\_username) | The username for the helm repository | `string` | `""` | no |
| <a name="input_igs_profile_snapshots"></a> [igs\_profile\_snapshots](#input\_igs\_profile\_snapshots) | Defines the FHIR Profile Version for IGS to be used in the DEMIS Environment | `string` | n/a | yes |
| <a name="input_is_local_mode"></a> [is\_local\_mode](#input\_is\_local\_mode) | Defines if the deployment is in local mode | `bool` | `false` | no |
| <a name="input_istio_enabled"></a> [istio\_enabled](#input\_istio\_enabled) | Enable istio for the application | `bool` | `true` | no |
| <a name="input_istio_routing_chart_version"></a> [istio\_routing\_chart\_version](#input\_istio\_routing\_chart\_version) | The version of the istio routing chart to use | `string` | n/a | yes |
| <a name="input_keycloak_internal_hostname"></a> [keycloak\_internal\_hostname](#input\_keycloak\_internal\_hostname) | The URL to the Keycloak Service in the internal network | `string` | `"keycloak.idm.svc.cluster.local"` | no |
| <a name="input_meldung_hostname"></a> [meldung\_hostname](#input\_meldung\_hostname) | The URL for accessing the DEMIS Notification Portal over Internet | `string` | `"meldung"` | no |
| <a name="input_portal_hostname"></a> [portal\_hostname](#input\_portal\_hostname) | The URL for accessing the DEMIS Notification Portal over Telematikinfrastruktur (TI) | `string` | `"portal"` | no |
| <a name="input_production_mode"></a> [production\_mode](#input\_production\_mode) | Enables the frontend production mode | `bool` | n/a | yes |
| <a name="input_pull_secrets"></a> [pull\_secrets](#input\_pull\_secrets) | The list of pull secrets to be used for downloading Docker Images | `list(string)` | `[]` | no |
| <a name="input_redis_cus_reader_user"></a> [redis\_cus\_reader\_user](#input\_redis\_cus\_reader\_user) | The Redis CUS User (with Reader Permissions) | `string` | n/a | yes |
| <a name="input_resource_definitions"></a> [resource\_definitions](#input\_resource\_definitions) | Defines a list of definition of resources that belong to a service | <pre>map(object({<br/>    resource_block = optional(string)<br/>    replicas       = number<br/>  }))</pre> | `{}` | no |
| <a name="input_routing_data_version"></a> [routing\_data\_version](#input\_routing\_data\_version) | Defines the Version of the Routing Data to be used in the DEMIS Environment | `string` | n/a | yes |
| <a name="input_s3_hostname"></a> [s3\_hostname](#input\_s3\_hostname) | The Hostname of the Remote S3 Storage | `string` | `""` | no |
| <a name="input_s3_port"></a> [s3\_port](#input\_s3\_port) | The Port of the Remote S3 Storage | `number` | `9000` | no |
| <a name="input_storage_hostname"></a> [storage\_hostname](#input\_storage\_hostname) | The URL to access the S3 compatible storage (minio) | `string` | `"storage"` | no |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | The namespace to deploy the application to | `string` | `"demis"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fsp_enabled"></a> [fsp\_enabled](#output\_fsp\_enabled) | Whether FHIR-Storage-Purger is enabled |
| <a name="output_fsp_version"></a> [fsp\_version](#output\_fsp\_version) | The version of FHIR-Storage-Purger |
<!-- END_TF_DOCS -->