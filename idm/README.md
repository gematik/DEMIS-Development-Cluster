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
| <a name="module_endpoints"></a> [endpoints](#module\_endpoints) | ../modules/endpoints | n/a |
| <a name="module_idm_services"></a> [idm\_services](#module\_idm\_services) | ./applications | n/a |
| <a name="module_persistent_volume_claims"></a> [persistent\_volume\_claims](#module\_persistent\_volume\_claims) | ../modules/persistence_volume_claim | n/a |
| <a name="module_pull_secrets"></a> [pull\_secrets](#module\_pull\_secrets) | ../modules/pull_secret | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.authorization_policies_istio](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) | resource |
| [helm_release.kubernetes_network_policies](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) | resource |
| [helm_release.kyverno_admission_policies](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) | resource |
| [helm_release.network_rules_istio](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) | resource |
| [terraform_data.cus_manual_trigger](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.kup_manual_trigger](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bundid_idp_issuer_subdomain"></a> [bundid\_idp\_issuer\_subdomain](#input\_bundid\_idp\_issuer\_subdomain) | The BundID IDP Issuer URL to be used for the JSON Web Token (JWT) validation | `string` | `""` | no |
| <a name="input_bundid_idp_user_import_enabled"></a> [bundid\_idp\_user\_import\_enabled](#input\_bundid\_idp\_user\_import\_enabled) | Activate BundID IDP user import | `bool` | `false` | no |
| <a name="input_certificate_update_cron_schedule"></a> [certificate\_update\_cron\_schedule](#input\_certificate\_update\_cron\_schedule) | Defines the Cron Schedule for the Certificate Update Service | `string` | n/a | yes |
| <a name="input_certificate_update_service_suspend"></a> [certificate\_update\_service\_suspend](#input\_certificate\_update\_service\_suspend) | Defines if the certificate-update-service is suspended. | `bool` | `false` | no |
| <a name="input_config_options"></a> [config\_options](#input\_config\_options) | Defines a list of configuration options that belong to services | <pre>list(object({<br/>    services     = list(string)<br/>    option_name  = string<br/>    option_value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_cus_health_department_certificates"></a> [cus\_health\_department\_certificates](#input\_cus\_health\_department\_certificates) | Base64-encoded GA certificates for local, ekm and live-test environment | `map(string)` | `{}` | no |
| <a name="input_database_credentials"></a> [database\_credentials](#input\_database\_credentials) | List of Database Credentials for DEMIS services (a secret) | <pre>list(object({<br/>    username            = string<br/>    password            = string<br/>    secret-name         = string<br/>    secret-key-user     = string<br/>    secret-key-password = string<br/>  }))</pre> | `[]` | no |
| <a name="input_database_target_host"></a> [database\_target\_host](#input\_database\_target\_host) | Defines the Hostname of the Database Server | `string` | n/a | yes |
| <a name="input_debug_enabled"></a> [debug\_enabled](#input\_debug\_enabled) | Defines if the backend Java Services must be started in Debug Mode | `bool` | `false` | no |
| <a name="input_docker_pull_secrets"></a> [docker\_pull\_secrets](#input\_docker\_pull\_secrets) | This Object contains the definition of Pull Secrets for accessing private repositories and pull Docker Images, using credentials.<br/><br/>  For credentials-based secrets, if the field "password\_type" is "token", <br/>  then the value of the variable "google\_cloud\_access\_token" will be used instead.<br/><br/>  If the field "password\_type" is set to "json\_key", the value of the field "user\_password" will be used as a Base64-encoded JSON Key. | <pre>list(object({<br/>    name          = string<br/>    registry      = string<br/>    user_name     = string<br/>    user_email    = string<br/>    user_password = string<br/>    password_type = string<br/>  }))</pre> | `[]` | no |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | The Docker Registry to use for pulling Images | `string` | n/a | yes |
| <a name="input_feature_flags"></a> [feature\_flags](#input\_feature\_flags) | Defines a list of feature flags that belong to services | <pre>list(object({<br/>    services   = list(string)<br/>    flag_name  = string<br/>    flag_value = bool<br/>  }))</pre> | `[]` | no |
| <a name="input_google_cloud_access_token"></a> [google\_cloud\_access\_token](#input\_google\_cloud\_access\_token) | The User-Token for accessing the Google Artifact Registry. <br/>  Typically obtained with the command: 'gcloud auth print-access-token' | `string` | `""` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | The Helm Repository where is stored the Helm Chart | `string` | n/a | yes |
| <a name="input_helm_repository_password"></a> [helm\_repository\_password](#input\_helm\_repository\_password) | The Password credential for the Helm Repository | `string` | `""` | no |
| <a name="input_helm_repository_username"></a> [helm\_repository\_username](#input\_helm\_repository\_username) | The Username credential for the Helm Repository | `string` | `""` | no |
| <a name="input_istio_enabled"></a> [istio\_enabled](#input\_istio\_enabled) | Defines if Istio Settings are enabled for the given target namespace | `bool` | `true` | no |
| <a name="input_keycloak_admin_password"></a> [keycloak\_admin\_password](#input\_keycloak\_admin\_password) | The Admin Password for Keycloak | `string` | n/a | yes |
| <a name="input_keycloak_admin_user"></a> [keycloak\_admin\_user](#input\_keycloak\_admin\_user) | The Admin User for Keycloak | `string` | n/a | yes |
| <a name="input_keycloak_cus_client_secret"></a> [keycloak\_cus\_client\_secret](#input\_keycloak\_cus\_client\_secret) | client secret of cus-cli (service account) in realm oegd | `string` | n/a | yes |
| <a name="input_keycloak_portal_admin_password"></a> [keycloak\_portal\_admin\_password](#input\_keycloak\_portal\_admin\_password) | The Admin Password for Keycloak PORTAL-Realm | `string` | n/a | yes |
| <a name="input_keycloak_portal_admin_user"></a> [keycloak\_portal\_admin\_user](#input\_keycloak\_portal\_admin\_user) | The Admin User for Keycloak PORTAL-Realm | `string` | n/a | yes |
| <a name="input_keycloak_portal_client_id"></a> [keycloak\_portal\_client\_id](#input\_keycloak\_portal\_client\_id) | The Client-ID for Keycloak PORTAL-Realm | `string` | n/a | yes |
| <a name="input_keycloak_portal_client_secret"></a> [keycloak\_portal\_client\_secret](#input\_keycloak\_portal\_client\_secret) | The Client-Secret for Keycloak PORTAL-Realm | `string` | n/a | yes |
| <a name="input_keycloak_truststore_jks"></a> [keycloak\_truststore\_jks](#input\_keycloak\_truststore\_jks) | The Truststore JKS for Keycloak in Base64 Format | `string` | n/a | yes |
| <a name="input_keycloak_truststore_password"></a> [keycloak\_truststore\_password](#input\_keycloak\_truststore\_password) | The Truststore Password for Keycloak | `string` | n/a | yes |
| <a name="input_keycloak_user_import_enabled"></a> [keycloak\_user\_import\_enabled](#input\_keycloak\_user\_import\_enabled) | Activate Keycloak user import | `bool` | `false` | no |
| <a name="input_keycloak_user_purger_cron_schedule"></a> [keycloak\_user\_purger\_cron\_schedule](#input\_keycloak\_user\_purger\_cron\_schedule) | Defines the Cron Schedule for the Keycloak-User-Purger | `string` | n/a | yes |
| <a name="input_keycloak_user_purger_suspend"></a> [keycloak\_user\_purger\_suspend](#input\_keycloak\_user\_purger\_suspend) | Defines if the keycloak-user-purger is suspended. | `bool` | `false` | no |
| <a name="input_kms_encryption_key"></a> [kms\_encryption\_key](#input\_kms\_encryption\_key) | The GCP KMS encryption key for OpenTofu state encryption | `string` | `""` | no |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to the kubeconfig file for the cluster | `string` | `""` | no |
| <a name="input_override_stage_name"></a> [override\_stage\_name](#input\_override\_stage\_name) | Override the automatically detected stage name (optional) | `string` | `""` | no |
| <a name="input_postgres_root_ca_certificate"></a> [postgres\_root\_ca\_certificate](#input\_postgres\_root\_ca\_certificate) | The Root CA Certificate for the Postgres Database in PEM format, encoded in base64 | `string` | n/a | yes |
| <a name="input_postgres_server_certificate"></a> [postgres\_server\_certificate](#input\_postgres\_server\_certificate) | The Server Certificate for the Postgres Database in PEM format, encoded in base64 | `string` | n/a | yes |
| <a name="input_postgres_server_key"></a> [postgres\_server\_key](#input\_postgres\_server\_key) | The Server Key for the Postgres Database in PEM format, encoded in base64 | `string` | n/a | yes |
| <a name="input_redis_cus_reader_password"></a> [redis\_cus\_reader\_password](#input\_redis\_cus\_reader\_password) | The Redis CUS Password (Reader) | `string` | n/a | yes |
| <a name="input_redis_cus_reader_user"></a> [redis\_cus\_reader\_user](#input\_redis\_cus\_reader\_user) | The Redis CUS User (Reader) | `string` | n/a | yes |
| <a name="input_redis_cus_writer_password"></a> [redis\_cus\_writer\_password](#input\_redis\_cus\_writer\_password) | The Redis CUS Password (Writer) | `string` | n/a | yes |
| <a name="input_redis_cus_writer_user"></a> [redis\_cus\_writer\_user](#input\_redis\_cus\_writer\_user) | The Redis CUS User (Writer) | `string` | n/a | yes |
| <a name="input_reset_values"></a> [reset\_values](#input\_reset\_values) | Reset the values to the ones built into the chart. This will override any custom values and reuse\_values settings. | `bool` | `false` | no |
| <a name="input_resource_definitions"></a> [resource\_definitions](#input\_resource\_definitions) | Defines a list of definition of resources that belong to a service | <pre>list(object({<br/>    service  = string<br/>    replicas = number<br/>    resources = optional(object({<br/>      limits = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>      requests = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>    }))<br/>    istio_proxy_resources = optional(object({<br/>      limits = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>      requests = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_root_ca_certificate"></a> [root\_ca\_certificate](#input\_root\_ca\_certificate) | The LDAP Root CA Certificate | `string` | n/a | yes |
| <a name="input_stage_configuration_data_name"></a> [stage\_configuration\_data\_name](#input\_stage\_configuration\_data\_name) | Defines the Name of the Stage Configuration Data to be used in the DEMIS Environment | `string` | n/a | yes |
| <a name="input_sub_ca_certificate"></a> [sub\_ca\_certificate](#input\_sub\_ca\_certificate) | The LDAP Sub CA Certificate | `string` | n/a | yes |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | The Namespace to use for deployment | `string` | `"idm"` | no |
| <a name="input_ti_idp_client_name"></a> [ti\_idp\_client\_name](#input\_ti\_idp\_client\_name) | The client name for access the DEMIS Notification Portal over the Telematikinfrastruktur (TI) | `string` | `""` | no |
| <a name="input_ti_idp_redirect_uri"></a> [ti\_idp\_redirect\_uri](#input\_ti\_idp\_redirect\_uri) | The redirect uri to access the DEMIS Notification Portal over the Telematikinfrastruktur (TI) | `string` | `""` | no |
| <a name="input_ti_idp_return_sso_token"></a> [ti\_idp\_return\_sso\_token](#input\_ti\_idp\_return\_sso\_token) | Activate return sso token for access the DEMIS Notification Portal over the Telematikinfrastruktur (TI) | `string` | `"true"` | no |
| <a name="input_ti_idp_server_url"></a> [ti\_idp\_server\_url](#input\_ti\_idp\_server\_url) | The server url for DEMIS Notification Portal over the Telematikinfrastruktur (TI) | `string` | `""` | no |
| <a name="input_ti_idp_subdomain"></a> [ti\_idp\_subdomain](#input\_ti\_idp\_subdomain) | The URL to access the DEMIS Notification Portal over the Telematikinfrastruktur (TI) | `string` | `"ti-idp"` | no |
| <a name="input_timeout_retry_overrides"></a> [timeout\_retry\_overrides](#input\_timeout\_retry\_overrides) | Defines retry and timeout configurations per service. Each definition must include a service name and can optionally include timeout and retry settings. | <pre>list(object({<br/>    service = string<br/>    timeout = optional(string)<br/>    retries = optional(object({<br/>      enable        = optional(bool)<br/>      attempts      = optional(number)<br/>      perTryTimeout = optional(string)<br/>      retryOn       = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_tsl_download_endpoint"></a> [tsl\_download\_endpoint](#input\_tsl\_download\_endpoint) | Defines the TSL download endpoint for keycloak | `string` | `""` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | Defines the volumes to be used for the Identity Management services | <pre>map(object({<br/>    storage_class = string<br/>    capacity      = string<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_encryption_key_used"></a> [kms\_encryption\_key\_used](#output\_kms\_encryption\_key\_used) | The flag to indicate if the KMS encryption key is used |
| <a name="output_service_config_options"></a> [service\_config\_options](#output\_service\_config\_options) | Current ops flags defined in the stage |
| <a name="output_service_feature_flags"></a> [service\_feature\_flags](#output\_service\_feature\_flags) | Current feature flags defined in the stage |
| <a name="output_stage_configuration_data_name"></a> [stage\_configuration\_data\_name](#output\_stage\_configuration\_data\_name) | Name of the Stage Configuration Data |
| <a name="output_stage_name"></a> [stage\_name](#output\_stage\_name) | Current stage |
| <a name="output_version_istio_routing_chart"></a> [version\_istio\_routing\_chart](#output\_version\_istio\_routing\_chart) | Version of the Istio Routing Chart being used |
| <a name="output_version_stage_configuration_data"></a> [version\_stage\_configuration\_data](#output\_version\_stage\_configuration\_data) | Version of the Stage Configuration Data |
<!-- END_TF_DOCS -->