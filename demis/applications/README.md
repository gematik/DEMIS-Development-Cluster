# applications

Module responsible for deploying the DEMIS Services Helm Charts in a Kubernetes Cluster.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0, < 4.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.38.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ars_service"></a> [ars\_service](#module\_ars\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_context_enrichment_service"></a> [context\_enrichment\_service](#module\_context\_enrichment\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_destination_lookup_purger"></a> [destination\_lookup\_purger](#module\_destination\_lookup\_purger) | ../../modules/helm_deployment | n/a |
| <a name="module_destination_lookup_reader"></a> [destination\_lookup\_reader](#module\_destination\_lookup\_reader) | ../../modules/helm_deployment | n/a |
| <a name="module_destination_lookup_writer"></a> [destination\_lookup\_writer](#module\_destination\_lookup\_writer) | ../../modules/helm_deployment | n/a |
| <a name="module_fhir_storage_purger"></a> [fhir\_storage\_purger](#module\_fhir\_storage\_purger) | ../../modules/helm_deployment | n/a |
| <a name="module_fhir_storage_reader"></a> [fhir\_storage\_reader](#module\_fhir\_storage\_reader) | ../../modules/helm_deployment | n/a |
| <a name="module_fhir_storage_writer"></a> [fhir\_storage\_writer](#module\_fhir\_storage\_writer) | ../../modules/helm_deployment | n/a |
| <a name="module_futs_core"></a> [futs\_core](#module\_futs\_core) | ../../modules/helm_deployment | n/a |
| <a name="module_futs_core_metadata"></a> [futs\_core\_metadata](#module\_futs\_core\_metadata) | ../../modules/fhir-profiles-metadata | n/a |
| <a name="module_futs_igs"></a> [futs\_igs](#module\_futs\_igs) | ../../modules/helm_deployment | n/a |
| <a name="module_futs_igs_metadata"></a> [futs\_igs\_metadata](#module\_futs\_igs\_metadata) | ../../modules/fhir-profiles-metadata | n/a |
| <a name="module_gateway_igs"></a> [gateway\_igs](#module\_gateway\_igs) | ../../modules/helm_deployment | n/a |
| <a name="module_hospital_location_service"></a> [hospital\_location\_service](#module\_hospital\_location\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_igs_service"></a> [igs\_service](#module\_igs\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_lifecycle_validation_service"></a> [lifecycle\_validation\_service](#module\_lifecycle\_validation\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_minio"></a> [minio](#module\_minio) | ../../modules/helm_deployment | n/a |
| <a name="module_notification_gateway"></a> [notification\_gateway](#module\_notification\_gateway) | ../../modules/helm_deployment | n/a |
| <a name="module_notification_processing_service"></a> [notification\_processing\_service](#module\_notification\_processing\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_notification_routing_service"></a> [notification\_routing\_service](#module\_notification\_routing\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_package_registry"></a> [package\_registry](#module\_package\_registry) | ../../modules/helm_deployment | n/a |
| <a name="module_pdfgen_service"></a> [pdfgen\_service](#module\_pdfgen\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_pgbouncer"></a> [pgbouncer](#module\_pgbouncer) | ../../modules/helm_deployment | n/a |
| <a name="module_portal_bedoccupancy"></a> [portal\_bedoccupancy](#module\_portal\_bedoccupancy) | ../../modules/helm_deployment | n/a |
| <a name="module_portal_disease"></a> [portal\_disease](#module\_portal\_disease) | ../../modules/helm_deployment | n/a |
| <a name="module_portal_igs"></a> [portal\_igs](#module\_portal\_igs) | ../../modules/helm_deployment | n/a |
| <a name="module_portal_pathogen"></a> [portal\_pathogen](#module\_portal\_pathogen) | ../../modules/helm_deployment | n/a |
| <a name="module_portal_shell"></a> [portal\_shell](#module\_portal\_shell) | ../../modules/helm_deployment | n/a |
| <a name="module_postgres"></a> [postgres](#module\_postgres) | ../../modules/helm_deployment | n/a |
| <a name="module_pseudonymization_service"></a> [pseudonymization\_service](#module\_pseudonymization\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_report_processing_service"></a> [report\_processing\_service](#module\_report\_processing\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_surveillance_pseudonym_purger_ars"></a> [surveillance\_pseudonym\_purger\_ars](#module\_surveillance\_pseudonym\_purger\_ars) | ../../modules/helm_deployment | n/a |
| <a name="module_surveillance_pseudonym_service_ars"></a> [surveillance\_pseudonym\_service\_ars](#module\_surveillance\_pseudonym\_service\_ars) | ../../modules/helm_deployment | n/a |
| <a name="module_terminology_server"></a> [terminology\_server](#module\_terminology\_server) | ../../modules/helm_deployment | n/a |
| <a name="module_validation_service_ars"></a> [validation\_service\_ars](#module\_validation\_service\_ars) | ../../modules/helm_deployment | n/a |
| <a name="module_validation_service_ars_metadata"></a> [validation\_service\_ars\_metadata](#module\_validation\_service\_ars\_metadata) | ../../modules/fhir-profiles-metadata | n/a |
| <a name="module_validation_service_core"></a> [validation\_service\_core](#module\_validation\_service\_core) | ../../modules/helm_deployment | n/a |
| <a name="module_validation_service_core_metadata"></a> [validation\_service\_core\_metadata](#module\_validation\_service\_core\_metadata) | ../../modules/fhir-profiles-metadata | n/a |
| <a name="module_validation_service_igs"></a> [validation\_service\_igs](#module\_validation\_service\_igs) | ../../modules/helm_deployment | n/a |
| <a name="module_validation_service_igs_metadata"></a> [validation\_service\_igs\_metadata](#module\_validation\_service\_igs\_metadata) | ../../modules/fhir-profiles-metadata | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.futs](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.validation_service](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_secret.ars_pseudo_hash_pepper](https://registry.terraform.io/providers/hashicorp/kubernetes/2.38.0/docs/resources/secret) | resource |
| [kubernetes_secret.database_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/2.38.0/docs/resources/secret) | resource |
| [kubernetes_secret.igs_encryption_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/2.38.0/docs/resources/secret) | resource |
| [kubernetes_secret.minio_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/2.38.0/docs/resources/secret) | resource |
| [kubernetes_secret.pgbouncer_userlist](https://registry.terraform.io/providers/hashicorp/kubernetes/2.38.0/docs/resources/secret) | resource |
| [kubernetes_secret.postgresql_tls_certificates](https://registry.terraform.io/providers/hashicorp/kubernetes/2.38.0/docs/resources/secret) | resource |
| [kubernetes_secret.redis_cus_reader_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/2.38.0/docs/resources/secret) | resource |
| [kubernetes_secret.service_accounts](https://registry.terraform.io/providers/hashicorp/kubernetes/2.38.0/docs/resources/secret) | resource |
| [terraform_data.validation_service_ars_http_rules](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.validation_service_core_http_rules](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.validation_service_igs_http_rules](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ars_pseudo_hash_pepper"></a> [ars\_pseudo\_hash\_pepper](#input\_ars\_pseudo\_hash\_pepper) | The Pepper used for the ARS Pseudo Hashing (Base64-encoded) | `string` | `null` | no |
| <a name="input_auth_hostname"></a> [auth\_hostname](#input\_auth\_hostname) | The Keycloak Issuer URL to be used for the JSON Web Token (JWT) validation | `string` | `"auth"` | no |
| <a name="input_cluster_gateway"></a> [cluster\_gateway](#input\_cluster\_gateway) | Defines the Istio Cluster Gateway to be used | `string` | `"mesh/demis-core-gateway"` | no |
| <a name="input_config_options"></a> [config\_options](#input\_config\_options) | Defines a list of ops flags to be bound in services | `map(map(string))` | `{}` | no |
| <a name="input_context_path"></a> [context\_path](#input\_context\_path) | The context path for reaching the DEMIS Services externally | `string` | `""` | no |
| <a name="input_core_hostname"></a> [core\_hostname](#input\_core\_hostname) | The URL to access the DEMIS Core API | `string` | `""` | no |
| <a name="input_database_credentials"></a> [database\_credentials](#input\_database\_credentials) | List of Database Credentials for DEMIS services (a secret) | <pre>list(object({<br/>    username            = string<br/>    password            = string<br/>    secret-name         = string<br/>    secret-key-user     = string<br/>    secret-key-password = string<br/>  }))</pre> | `[]` | no |
| <a name="input_database_target_host"></a> [database\_target\_host](#input\_database\_target\_host) | Defines the Hostname of the Database Server | `string` | n/a | yes |
| <a name="input_debug_enabled"></a> [debug\_enabled](#input\_debug\_enabled) | Defines if the backend Java Services must be started in Debug Mode | `bool` | `false` | no |
| <a name="input_deployment_information"></a> [deployment\_information](#input\_deployment\_information) | Structure holding deployment information for the Helm Charts | <pre>map(object({<br/>    chart-name          = optional(string) # Optional, uses a different Helm Chart name than the application name<br/>    image-tag           = optional(string) # Optional, uses a different image tag for the deployment<br/>    deployment-strategy = string<br/>    enabled             = bool<br/>    main = object({<br/>      version  = string<br/>      weight   = number<br/>      profiles = optional(list(string))<br/>    })<br/>    canary = optional(object({<br/>      version  = optional(string)<br/>      weight   = optional(string)<br/>      profiles = optional(list(string))<br/>    }), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_destination_lookup_purger_cron_schedule"></a> [destination\_lookup\_purger\_cron\_schedule](#input\_destination\_lookup\_purger\_cron\_schedule) | Defines the Cron Schedule for the destination-lookup-purger | `string` | n/a | yes |
| <a name="input_destination_lookup_purger_suspend"></a> [destination\_lookup\_purger\_suspend](#input\_destination\_lookup\_purger\_suspend) | Defines if the destination-lookup-purger is suspended. | `bool` | `false` | no |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | The docker registry to use for the application | `string` | n/a | yes |
| <a name="input_external_chart_path"></a> [external\_chart\_path](#input\_external\_chart\_path) | The path to the stage-dependent Helm Chart Values. | `string` | n/a | yes |
| <a name="input_feature_flags"></a> [feature\_flags](#input\_feature\_flags) | Defines a list of feature flags to be bound in services | `map(map(bool))` | `{}` | no |
| <a name="input_fhir_storage_purger_cron_schedule"></a> [fhir\_storage\_purger\_cron\_schedule](#input\_fhir\_storage\_purger\_cron\_schedule) | Defines the Cron Schedule for the FHIR storage purger | `string` | n/a | yes |
| <a name="input_fhir_storage_purger_suspend"></a> [fhir\_storage\_purger\_suspend](#input\_fhir\_storage\_purger\_suspend) | Defines if the fhir-storage-purger is suspended. | `bool` | `false` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | The helm repository to use for the application | `string` | n/a | yes |
| <a name="input_helm_repository_password"></a> [helm\_repository\_password](#input\_helm\_repository\_password) | The password for the helm repository | `string` | `""` | no |
| <a name="input_helm_repository_username"></a> [helm\_repository\_username](#input\_helm\_repository\_username) | The username for the helm repository | `string` | `""` | no |
| <a name="input_is_local_mode"></a> [is\_local\_mode](#input\_is\_local\_mode) | Defines if the deployment is in local mode | `bool` | `false` | no |
| <a name="input_istio_enabled"></a> [istio\_enabled](#input\_istio\_enabled) | Enable istio for the application | `bool` | `true` | no |
| <a name="input_istio_proxy_default_resources"></a> [istio\_proxy\_default\_resources](#input\_istio\_proxy\_default\_resources) | Default values for istio proxy resource requests and limits | <pre>object({<br/>    limits = object({<br/>      cpu    = optional(string)<br/>      memory = string<br/>    })<br/>    requests = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_keycloak_internal_hostname"></a> [keycloak\_internal\_hostname](#input\_keycloak\_internal\_hostname) | The URL to the Keycloak Service in the internal network | `string` | `"keycloak.idm.svc.cluster.local"` | no |
| <a name="input_meldung_hostname"></a> [meldung\_hostname](#input\_meldung\_hostname) | The URL for accessing the DEMIS Notification Portal over Internet | `string` | `"meldung"` | no |
| <a name="input_minio_root_password"></a> [minio\_root\_password](#input\_minio\_root\_password) | The Minio Root Password | `string` | n/a | yes |
| <a name="input_minio_root_user"></a> [minio\_root\_user](#input\_minio\_root\_user) | The Minio Root User | `string` | n/a | yes |
| <a name="input_portal_hostname"></a> [portal\_hostname](#input\_portal\_hostname) | The URL for accessing the DEMIS Notification Portal over Telematikinfrastruktur (TI) | `string` | `"portal"` | no |
| <a name="input_postgres_root_ca_certificate"></a> [postgres\_root\_ca\_certificate](#input\_postgres\_root\_ca\_certificate) | The Root CA Certificate for the Postgres Database in PEM format, encoded in base64 | `string` | n/a | yes |
| <a name="input_postgres_server_certificate"></a> [postgres\_server\_certificate](#input\_postgres\_server\_certificate) | The Server Certificate for the Postgres Database in PEM format, encoded in base64 | `string` | n/a | yes |
| <a name="input_postgres_server_key"></a> [postgres\_server\_key](#input\_postgres\_server\_key) | The Server Key for the Postgres Database in PEM format, encoded in base64 | `string` | n/a | yes |
| <a name="input_production_mode"></a> [production\_mode](#input\_production\_mode) | Enables the frontend production mode | `bool` | n/a | yes |
| <a name="input_profile_provisioning_mode_vs_ars"></a> [profile\_provisioning\_mode\_vs\_ars](#input\_profile\_provisioning\_mode\_vs\_ars) | Provisioning mode for the FHIR Profiles services. Allowed values are: dedicated, distributed, combined | `string` | `null` | no |
| <a name="input_profile_provisioning_mode_vs_core"></a> [profile\_provisioning\_mode\_vs\_core](#input\_profile\_provisioning\_mode\_vs\_core) | Provisioning mode for the FHIR Profiles services. Allowed values are: dedicated, distributed, combined | `string` | `null` | no |
| <a name="input_profile_provisioning_mode_vs_igs"></a> [profile\_provisioning\_mode\_vs\_igs](#input\_profile\_provisioning\_mode\_vs\_igs) | Provisioning mode for the FHIR Profiles services. Allowed values are: dedicated, distributed, combined | `string` | `null` | no |
| <a name="input_pull_secrets"></a> [pull\_secrets](#input\_pull\_secrets) | The list of pull secrets to be used for downloading Docker Images | `list(string)` | `[]` | no |
| <a name="input_redis_cus_reader_password"></a> [redis\_cus\_reader\_password](#input\_redis\_cus\_reader\_password) | The Redis CUS Password (Reader) | `string` | n/a | yes |
| <a name="input_redis_cus_reader_user"></a> [redis\_cus\_reader\_user](#input\_redis\_cus\_reader\_user) | The Redis CUS User (Reader) | `string` | n/a | yes |
| <a name="input_reset_values"></a> [reset\_values](#input\_reset\_values) | Reset the values to the ones built into the chart. This will override any custom values and reuse\_values settings. | `bool` | `false` | no |
| <a name="input_resource_definitions"></a> [resource\_definitions](#input\_resource\_definitions) | Defines a list of definition of resources that belong to a service | <pre>map(object({<br/>    resource_block = optional(string)<br/>    istio_proxy_resources = optional(object({<br/>      limits = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>      requests = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>    }))<br/>    replicas = number<br/>  }))</pre> | `{}` | no |
| <a name="input_s3_hostname"></a> [s3\_hostname](#input\_s3\_hostname) | The Hostname of the Remote S3 Storage | `string` | `""` | no |
| <a name="input_s3_port"></a> [s3\_port](#input\_s3\_port) | The Port of the Remote S3 Storage | `number` | `9000` | no |
| <a name="input_s3_tls_credential"></a> [s3\_tls\_credential](#input\_s3\_tls\_credential) | Base64-encoded, PEM certificate to be used for configuring the TLS Settings for the S3 Storage Server Connection. | `string` | n/a | yes |
| <a name="input_service_accounts"></a> [service\_accounts](#input\_service\_accounts) | Service account details for authentication | <pre>list(object({<br/>    secret_name    = string # Name of the Kubernetes secret to store the service account key<br/>    keyfile_base64 = string # Base64-encoded JSON key file content<br/>  }))</pre> | `[]` | no |
| <a name="input_storage_hostname"></a> [storage\_hostname](#input\_storage\_hostname) | The URL to access the S3 compatible storage (minio) | `string` | `"storage"` | no |
| <a name="input_storage_tls_certificate"></a> [storage\_tls\_certificate](#input\_storage\_tls\_certificate) | CA certificate of storage when accessing externally | `string` | n/a | yes |
| <a name="input_surveillance_pseudonym_purger_ars_cron_schedule"></a> [surveillance\_pseudonym\_purger\_ars\_cron\_schedule](#input\_surveillance\_pseudonym\_purger\_ars\_cron\_schedule) | Defines the Cron Schedule for the surveillance-pseudonym-purger-ars | `string` | n/a | yes |
| <a name="input_surveillance_pseudonym_purger_ars_suspend"></a> [surveillance\_pseudonym\_purger\_ars\_suspend](#input\_surveillance\_pseudonym\_purger\_ars\_suspend) | Defines if the surveillance-pseudonym-purger-ars is suspended. | `bool` | `false` | no |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | The namespace to deploy the application to | `string` | `"demis"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ars_profile_snapshots"></a> [ars\_profile\_snapshots](#output\_ars\_profile\_snapshots) | Version of the ARS Profile Snapshots being used |
| <a name="output_dlp_enabled"></a> [dlp\_enabled](#output\_dlp\_enabled) | Whether destination-lookup-purger is enabled |
| <a name="output_dlp_version"></a> [dlp\_version](#output\_dlp\_version) | The version of destination-lookup-purger |
| <a name="output_fhir_profile_snapshots"></a> [fhir\_profile\_snapshots](#output\_fhir\_profile\_snapshots) | Version of the FHIR Profile Snapshots being used |
| <a name="output_fsp_enabled"></a> [fsp\_enabled](#output\_fsp\_enabled) | Whether FHIR-Storage-Purger is enabled |
| <a name="output_fsp_version"></a> [fsp\_version](#output\_fsp\_version) | The version of FHIR-Storage-Purger |
| <a name="output_igs_profile_snapshots"></a> [igs\_profile\_snapshots](#output\_igs\_profile\_snapshots) | Version of the IGS Profile Snapshots being used |
| <a name="output_spp_ars_enabled"></a> [spp\_ars\_enabled](#output\_spp\_ars\_enabled) | Whether Surveillance-Pseudonym-Purger-ARS is enabled |
| <a name="output_spp_ars_version"></a> [spp\_ars\_version](#output\_spp\_ars\_version) | The version of Surveillance-Pseudonym-Purger-ARS |
| <a name="output_version_istio_routing_chart"></a> [version\_istio\_routing\_chart](#output\_version\_istio\_routing\_chart) | Version of the Istio Routing Chart being used |
| <a name="output_version_routing_data"></a> [version\_routing\_data](#output\_version\_routing\_data) | Version of the Routing Data |
<!-- END_TF_DOCS -->