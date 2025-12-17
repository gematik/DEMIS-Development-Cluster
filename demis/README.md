# demis

Module responsible for configuring and deploying the DEMIS Services in a Kubernetes Cluster.

It performs the following operations:

- creates a Namespace where to deploy the different Kubernetes Objects
- creates Secrets
- creates ConfigMaps for Feature/Ops Flags
- creates PersistenceVolumeClaims
- deploys the Helm Charts for the services

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.1.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 3.0.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_activate_maintenance_mode"></a> [activate\_maintenance\_mode](#module\_activate\_maintenance\_mode) | ../modules/maintenance_mode | n/a |
| <a name="module_application_flags"></a> [application\_flags](#module\_application\_flags) | ../modules/flags | n/a |
| <a name="module_application_resources"></a> [application\_resources](#module\_application\_resources) | ../modules/resources | n/a |
| <a name="module_deactivate_maintenance_mode"></a> [deactivate\_maintenance\_mode](#module\_deactivate\_maintenance\_mode) | ../modules/maintenance_mode | n/a |
| <a name="module_demis_namespace"></a> [demis\_namespace](#module\_demis\_namespace) | ../modules/namespace | n/a |
| <a name="module_demis_services"></a> [demis\_services](#module\_demis\_services) | ./applications | n/a |
| <a name="module_endpoints"></a> [endpoints](#module\_endpoints) | ../modules/endpoints | n/a |
| <a name="module_persistent_volume_claims"></a> [persistent\_volume\_claims](#module\_persistent\_volume\_claims) | ../modules/persistence_volume_claim | n/a |
| <a name="module_pull_secrets"></a> [pull\_secrets](#module\_pull\_secrets) | ../modules/pull_secret | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.authentication_policies_istio](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) | resource |
| [helm_release.authorization_policies_istio](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) | resource |
| [helm_release.kubernetes_network_policies](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) | resource |
| [helm_release.kyverno_admission_policies](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) | resource |
| [helm_release.network_rules_istio](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) | resource |
| [terraform_data.dlp_manual_trigger](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.fsp_manual_trigger](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.spp_ars_manual_trigger](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ars_pseudo_hash_pepper"></a> [ars\_pseudo\_hash\_pepper](#input\_ars\_pseudo\_hash\_pepper) | The Pepper used for the ARS Pseudo Hashing (Base64-encoded) | `string` | `null` | no |
| <a name="input_config_options"></a> [config\_options](#input\_config\_options) | Defines a list of configuration options that belong to services | <pre>list(object({<br/>    services     = list(string)<br/>    option_name  = string<br/>    option_value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_context_path"></a> [context\_path](#input\_context\_path) | The context path for reaching the DEMIS Services externally | `string` | `""` | no |
| <a name="input_database_credentials"></a> [database\_credentials](#input\_database\_credentials) | List of Database Credentials for DEMIS services (a secret) | <pre>list(object({<br/>    username            = string<br/>    password            = string<br/>    secret-name         = string<br/>    secret-key-user     = string<br/>    secret-key-password = string<br/>  }))</pre> | `[]` | no |
| <a name="input_database_target_host"></a> [database\_target\_host](#input\_database\_target\_host) | Defines the Hostname of the Database Server | `string` | n/a | yes |
| <a name="input_debug_enabled"></a> [debug\_enabled](#input\_debug\_enabled) | Defines if the backend Java Services must be started in Debug Mode | `bool` | `false` | no |
| <a name="input_destination_lookup_purger_cron_schedule"></a> [destination\_lookup\_purger\_cron\_schedule](#input\_destination\_lookup\_purger\_cron\_schedule) | Defines the cron schedule for the destination-lookup-purger | `string` | `"0 22 * * *"` | no |
| <a name="input_destination_lookup_purger_suspend"></a> [destination\_lookup\_purger\_suspend](#input\_destination\_lookup\_purger\_suspend) | Defines if the destination-lookup-purger is suspended. | `bool` | `false` | no |
| <a name="input_docker_pull_secrets"></a> [docker\_pull\_secrets](#input\_docker\_pull\_secrets) | This Object contains the definition of Pull Secrets for accessing private repositories and pull Docker Images, using credentials.<br/><br/>  For credentials-based secrets, if the field "password\_type" is "token", <br/>  then the value of the variable "google\_cloud\_access\_token" will be used instead.<br/><br/>  If the field "password\_type" is set to "json\_key", the value of the field "user\_password" will be used as a Base64-encoded JSON Key. | <pre>list(object({<br/>    name          = string<br/>    registry      = string<br/>    user_name     = string<br/>    user_email    = string<br/>    user_password = string<br/>    password_type = string<br/>  }))</pre> | `[]` | no |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | The Docker Registry to use for pulling Images | `string` | n/a | yes |
| <a name="input_feature_flags"></a> [feature\_flags](#input\_feature\_flags) | Defines a list of feature flags that belong to services | <pre>list(object({<br/>    services   = list(string)<br/>    flag_name  = string<br/>    flag_value = bool<br/>  }))</pre> | `[]` | no |
| <a name="input_fhir_storage_purger_cron_schedule"></a> [fhir\_storage\_purger\_cron\_schedule](#input\_fhir\_storage\_purger\_cron\_schedule) | Defines the cron schedule for the FHIR storage purger | `string` | n/a | yes |
| <a name="input_fhir_storage_purger_suspend"></a> [fhir\_storage\_purger\_suspend](#input\_fhir\_storage\_purger\_suspend) | Defines if the fhir-storage-purger is suspended. | `bool` | `false` | no |
| <a name="input_google_cloud_access_token"></a> [google\_cloud\_access\_token](#input\_google\_cloud\_access\_token) | The User-Token for accessing the Google Artifact Registry. <br/>  Typically obtained with the command: 'gcloud auth print-access-token' | `string` | `""` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | The Helm Repository where is stored the Helm Chart | `string` | n/a | yes |
| <a name="input_helm_repository_password"></a> [helm\_repository\_password](#input\_helm\_repository\_password) | The Password credential for the Helm Repository | `string` | `""` | no |
| <a name="input_helm_repository_username"></a> [helm\_repository\_username](#input\_helm\_repository\_username) | The Username credential for the Helm Repository | `string` | `""` | no |
| <a name="input_istio_enabled"></a> [istio\_enabled](#input\_istio\_enabled) | Defines if Istio Settings are enabled for the given target namespace | `bool` | `true` | no |
| <a name="input_kms_encryption_key"></a> [kms\_encryption\_key](#input\_kms\_encryption\_key) | The GCP KMS encryption key for OpenTofu state encryption | `string` | `""` | no |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to the kubeconfig file for the cluster | `string` | `""` | no |
| <a name="input_minio_root_password"></a> [minio\_root\_password](#input\_minio\_root\_password) | The Minio Root Password | `string` | n/a | yes |
| <a name="input_minio_root_user"></a> [minio\_root\_user](#input\_minio\_root\_user) | The Minio Root User | `string` | n/a | yes |
| <a name="input_override_stage_name"></a> [override\_stage\_name](#input\_override\_stage\_name) | Override the automatically detected stage name (optional) | `string` | `""` | no |
| <a name="input_postgres_root_ca_certificate"></a> [postgres\_root\_ca\_certificate](#input\_postgres\_root\_ca\_certificate) | The Root CA Certificate for the Postgres Database in PEM format, encoded in base64 | `string` | n/a | yes |
| <a name="input_postgres_server_certificate"></a> [postgres\_server\_certificate](#input\_postgres\_server\_certificate) | The Server Certificate for the Postgres Database in PEM format, encoded in base64 | `string` | n/a | yes |
| <a name="input_postgres_server_key"></a> [postgres\_server\_key](#input\_postgres\_server\_key) | The Server Key for the Postgres Database in PEM format, encoded in base64 | `string` | n/a | yes |
| <a name="input_profile_provisioning_mode_vs_ars"></a> [profile\_provisioning\_mode\_vs\_ars](#input\_profile\_provisioning\_mode\_vs\_ars) | Provisioning mode for the FHIR Profiles services. Allowed values are: dedicated, distributed, combined | `string` | `null` | no |
| <a name="input_profile_provisioning_mode_vs_core"></a> [profile\_provisioning\_mode\_vs\_core](#input\_profile\_provisioning\_mode\_vs\_core) | Provisioning mode for the FHIR Profiles services. Allowed values are: dedicated, distributed, combined | `string` | `null` | no |
| <a name="input_profile_provisioning_mode_vs_igs"></a> [profile\_provisioning\_mode\_vs\_igs](#input\_profile\_provisioning\_mode\_vs\_igs) | Provisioning mode for the FHIR Profiles services. Allowed values are: dedicated, distributed, combined | `string` | `null` | no |
| <a name="input_redis_cus_reader_password"></a> [redis\_cus\_reader\_password](#input\_redis\_cus\_reader\_password) | The Redis CUS Password (Reader) | `string` | n/a | yes |
| <a name="input_redis_cus_reader_user"></a> [redis\_cus\_reader\_user](#input\_redis\_cus\_reader\_user) | The Redis CUS User (Reader) | `string` | n/a | yes |
| <a name="input_reset_values"></a> [reset\_values](#input\_reset\_values) | Reset the values to the ones built into the chart. This will override any custom values and reuse\_values settings. | `bool` | `false` | no |
| <a name="input_resource_definitions"></a> [resource\_definitions](#input\_resource\_definitions) | Defines a list of definition of resources that belong to a service | <pre>list(object({<br/>    service  = string<br/>    replicas = number<br/>    resources = optional(object({<br/>      limits = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>      requests = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>    }))<br/>    istio_proxy_resources = optional(object({<br/>      limits = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>      requests = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_s3_hostname"></a> [s3\_hostname](#input\_s3\_hostname) | The Hostname of the Remote S3 Storage | `string` | `""` | no |
| <a name="input_s3_port"></a> [s3\_port](#input\_s3\_port) | The Port of the Remote S3 Storage | `number` | `9000` | no |
| <a name="input_s3_tls_credential"></a> [s3\_tls\_credential](#input\_s3\_tls\_credential) | Base64-encoded, PEM certificate to be used for configuring the TLS Settings for the S3 Storage Server Connection. | `string` | n/a | yes |
| <a name="input_service_accounts"></a> [service\_accounts](#input\_service\_accounts) | Service account details for authentication | <pre>list(object({<br/>    secret_name    = string # Name of the Kubernetes secret to store the service account key<br/>    keyfile_base64 = string # Base64-encoded JSON key file content<br/>  }))</pre> | `[]` | no |
| <a name="input_storage_tls_certificate"></a> [storage\_tls\_certificate](#input\_storage\_tls\_certificate) | CA certificate of storage when accessing externally | `string` | n/a | yes |
| <a name="input_surveillance_pseudonym_purger_ars_cron_schedule"></a> [surveillance\_pseudonym\_purger\_ars\_cron\_schedule](#input\_surveillance\_pseudonym\_purger\_ars\_cron\_schedule) | Defines the cron schedule for the surveillance-pseudonym-purger-ars | `string` | `"0 22 * * *"` | no |
| <a name="input_surveillance_pseudonym_purger_ars_suspend"></a> [surveillance\_pseudonym\_purger\_ars\_suspend](#input\_surveillance\_pseudonym\_purger\_ars\_suspend) | Defines if the surveillance-pseudonym-purger-ars is suspended. | `bool` | `false` | no |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | The Namespace to use for deployment | `string` | `"demis"` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | Defines the volumes to be used in the DEMIS Environment | <pre>map(object({<br/>    storage_class = string<br/>    capacity      = string<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ars_profile_snapshots"></a> [ars\_profile\_snapshots](#output\_ars\_profile\_snapshots) | Version of the ARS Profile Snapshots being used |
| <a name="output_kms_encryption_key_used"></a> [kms\_encryption\_key\_used](#output\_kms\_encryption\_key\_used) | The flag to indicate if the KMS encryption key is used |
| <a name="output_service_config_options"></a> [service\_config\_options](#output\_service\_config\_options) | Current ops flags defined in the stage |
| <a name="output_service_feature_flags"></a> [service\_feature\_flags](#output\_service\_feature\_flags) | Current feature flags defined in the stage |
| <a name="output_stage_name"></a> [stage\_name](#output\_stage\_name) | Current stage |
| <a name="output_version_fhir_profile_snapshots"></a> [version\_fhir\_profile\_snapshots](#output\_version\_fhir\_profile\_snapshots) | Version of the FHIR Profile Snapshots being used |
| <a name="output_version_igs_profile_snapshots"></a> [version\_igs\_profile\_snapshots](#output\_version\_igs\_profile\_snapshots) | Version of the IGS Profile Snapshots being used |
| <a name="output_version_istio_routing_chart"></a> [version\_istio\_routing\_chart](#output\_version\_istio\_routing\_chart) | Version of the Istio Routing Chart being used |
| <a name="output_version_routing_data"></a> [version\_routing\_data](#output\_version\_routing\_data) | Version of the Routing Data |
<!-- END_TF_DOCS -->