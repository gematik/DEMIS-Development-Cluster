# applications

Module responsible for deploying the DEMIS Services Helm Charts in a Kubernetes Cluster.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0.0, < 4.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bundid_idp"></a> [bundid\_idp](#module\_bundid\_idp) | ../../modules/helm_deployment | n/a |
| <a name="module_certificate_update_service"></a> [certificate\_update\_service](#module\_certificate\_update\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_gematik_idp"></a> [gematik\_idp](#module\_gematik\_idp) | ../../modules/helm_deployment | n/a |
| <a name="module_keycloak"></a> [keycloak](#module\_keycloak) | ../../modules/helm_deployment | n/a |
| <a name="module_keycloak_user_purger"></a> [keycloak\_user\_purger](#module\_keycloak\_user\_purger) | ../../modules/helm_deployment | n/a |
| <a name="module_pgbouncer"></a> [pgbouncer](#module\_pgbouncer) | ../../modules/helm_deployment | n/a |
| <a name="module_postgres"></a> [postgres](#module\_postgres) | ../../modules/helm_deployment | n/a |
| <a name="module_redis_cus"></a> [redis\_cus](#module\_redis\_cus) | ../../modules/helm_deployment | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_secret_v1.database_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.keycloak_admin_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.keycloak_cus_client_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.keycloak_portal_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.keycloak_truststore_file](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.keycloak_truststore_password](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.ldap_certificates](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.pgbouncer_userlist](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.postgresql_tls_certificates](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.redis_cus_acl](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.redis_cus_reader_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.redis_cus_writer_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth_hostname"></a> [auth\_hostname](#input\_auth\_hostname) | The Keycloak Issuer URL to be used for the JSON Web Token (JWT) validation | `string` | `"auth"` | no |
| <a name="input_bundid_idp_hostname"></a> [bundid\_idp\_hostname](#input\_bundid\_idp\_hostname) | The BundID IDP Issuer URL to be used for the JSON Web Token (JWT) validation | `string` | `""` | no |
| <a name="input_bundid_idp_user_import_enabled"></a> [bundid\_idp\_user\_import\_enabled](#input\_bundid\_idp\_user\_import\_enabled) | Activate BundID IDP user import | `bool` | n/a | yes |
| <a name="input_certificate_update_cron_schedule"></a> [certificate\_update\_cron\_schedule](#input\_certificate\_update\_cron\_schedule) | Defines the Cron Schedule for the Certificate Update Service | `string` | n/a | yes |
| <a name="input_certificate_update_service_suspend"></a> [certificate\_update\_service\_suspend](#input\_certificate\_update\_service\_suspend) | Defines if the certificate-update-service is suspended. | `bool` | `false` | no |
| <a name="input_cluster_gateway"></a> [cluster\_gateway](#input\_cluster\_gateway) | Defines the Istio Cluster Gateway to be used | `string` | `"mesh/demis-core-gateway"` | no |
| <a name="input_config_options"></a> [config\_options](#input\_config\_options) | Defines a list of ops flags to be bound in services | `map(map(string))` | `{}` | no |
| <a name="input_core_hostname"></a> [core\_hostname](#input\_core\_hostname) | The URL to access the DEMIS Core API | `string` | `""` | no |
| <a name="input_cus_health_department_certificates"></a> [cus\_health\_department\_certificates](#input\_cus\_health\_department\_certificates) | Base64-encoded GA certificates for local, ekm and live-test environment | `map(string)` | `{}` | no |
| <a name="input_database_credentials"></a> [database\_credentials](#input\_database\_credentials) | List of Database Credentials for DEMIS services (a secret) | <pre>list(object({<br/>    username            = string<br/>    password            = string<br/>    secret-name         = string<br/>    secret-key-user     = string<br/>    secret-key-password = string<br/>  }))</pre> | `[]` | no |
| <a name="input_database_target_host"></a> [database\_target\_host](#input\_database\_target\_host) | Defines the Hostname of the Database Server | `string` | n/a | yes |
| <a name="input_debug_enabled"></a> [debug\_enabled](#input\_debug\_enabled) | Defines if the backend Java Services must be started in Debug Mode | `bool` | `false` | no |
| <a name="input_deployment_information"></a> [deployment\_information](#input\_deployment\_information) | Structure holding deployment information for the Helm Charts | <pre>map(object({<br/>    chart-name          = optional(string) # Optional, uses a different Helm Chart name than the application name<br/>    image-tag           = optional(string) # Optional, uses a different image tag for the deployment<br/>    deployment-strategy = string<br/>    enabled             = bool<br/>    main = object({<br/>      version = string<br/>      weight  = number<br/>    })<br/>    canary = optional(object({<br/>      version = optional(string)<br/>      weight  = optional(string)<br/>    }), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | The docker registry to use for the application | `string` | n/a | yes |
| <a name="input_external_chart_path"></a> [external\_chart\_path](#input\_external\_chart\_path) | The path to the stage-dependent Helm Chart Values. | `string` | n/a | yes |
| <a name="input_feature_flags"></a> [feature\_flags](#input\_feature\_flags) | Defines a list of feature flags to be bound in services | `map(map(bool))` | `{}` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | The helm repository to use for the application | `string` | n/a | yes |
| <a name="input_helm_repository_password"></a> [helm\_repository\_password](#input\_helm\_repository\_password) | The password for the helm repository | `string` | `""` | no |
| <a name="input_helm_repository_username"></a> [helm\_repository\_username](#input\_helm\_repository\_username) | The username for the helm repository | `string` | `""` | no |
| <a name="input_is_local_mode"></a> [is\_local\_mode](#input\_is\_local\_mode) | Flag to define if the cluster is local | `bool` | `false` | no |
| <a name="input_istio_enabled"></a> [istio\_enabled](#input\_istio\_enabled) | Enable istio for the application | `bool` | `true` | no |
| <a name="input_istio_proxy_default_resources"></a> [istio\_proxy\_default\_resources](#input\_istio\_proxy\_default\_resources) | Default values for istio proxy resource requests and limits | <pre>object({<br/>    limits = object({<br/>      cpu    = optional(string)<br/>      memory = string<br/>    })<br/>    requests = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_keycloak_admin_password"></a> [keycloak\_admin\_password](#input\_keycloak\_admin\_password) | The Admin Password for Keycloak | `string` | n/a | yes |
| <a name="input_keycloak_admin_user"></a> [keycloak\_admin\_user](#input\_keycloak\_admin\_user) | The Admin User for Keycloak | `string` | n/a | yes |
| <a name="input_keycloak_cus_client_secret"></a> [keycloak\_cus\_client\_secret](#input\_keycloak\_cus\_client\_secret) | client secret of cus-cli (service account) in realm oegd | `string` | n/a | yes |
| <a name="input_keycloak_portal_admin_password"></a> [keycloak\_portal\_admin\_password](#input\_keycloak\_portal\_admin\_password) | The Admin Password for Keycloak PORTAL-Realm | `string` | n/a | yes |
| <a name="input_keycloak_portal_admin_user"></a> [keycloak\_portal\_admin\_user](#input\_keycloak\_portal\_admin\_user) | The Admin User for Keycloak PORTAL-Realm | `string` | n/a | yes |
| <a name="input_keycloak_portal_client_id"></a> [keycloak\_portal\_client\_id](#input\_keycloak\_portal\_client\_id) | The Client-ID for Keycloak PORTAL-Realm | `string` | n/a | yes |
| <a name="input_keycloak_portal_client_secret"></a> [keycloak\_portal\_client\_secret](#input\_keycloak\_portal\_client\_secret) | The Client-Secret for Keycloak PORTAL-Realm | `string` | n/a | yes |
| <a name="input_keycloak_truststore_jks"></a> [keycloak\_truststore\_jks](#input\_keycloak\_truststore\_jks) | The Truststore JKS for Keycloak in Base64 Format | `string` | n/a | yes |
| <a name="input_keycloak_truststore_password"></a> [keycloak\_truststore\_password](#input\_keycloak\_truststore\_password) | The Truststore Password for Keycloak | `string` | n/a | yes |
| <a name="input_keycloak_user_import_enabled"></a> [keycloak\_user\_import\_enabled](#input\_keycloak\_user\_import\_enabled) | Activate Keycloak user import | `bool` | n/a | yes |
| <a name="input_keycloak_user_purger_cron_schedule"></a> [keycloak\_user\_purger\_cron\_schedule](#input\_keycloak\_user\_purger\_cron\_schedule) | Defines the Cron Schedule for the Keycloak-User-Purger | `string` | n/a | yes |
| <a name="input_keycloak_user_purger_suspend"></a> [keycloak\_user\_purger\_suspend](#input\_keycloak\_user\_purger\_suspend) | Defines if the keycloak-user-purger is suspended. | `bool` | `false` | no |
| <a name="input_postgres_root_ca_certificate"></a> [postgres\_root\_ca\_certificate](#input\_postgres\_root\_ca\_certificate) | The Root CA Certificate for the Postgres Database in PEM format, encoded in base64 | `string` | n/a | yes |
| <a name="input_postgres_server_certificate"></a> [postgres\_server\_certificate](#input\_postgres\_server\_certificate) | The Server Certificate for the Postgres Database in PEM format, encoded in base64 | `string` | n/a | yes |
| <a name="input_postgres_server_key"></a> [postgres\_server\_key](#input\_postgres\_server\_key) | The Server Key for the Postgres Database in PEM format, encoded in base64 | `string` | n/a | yes |
| <a name="input_pull_secrets"></a> [pull\_secrets](#input\_pull\_secrets) | The list of pull secrets to be used for downloading Docker Images | `list(string)` | `[]` | no |
| <a name="input_redis_cus_reader_password"></a> [redis\_cus\_reader\_password](#input\_redis\_cus\_reader\_password) | The Redis CUS Password (Reader) | `string` | n/a | yes |
| <a name="input_redis_cus_reader_user"></a> [redis\_cus\_reader\_user](#input\_redis\_cus\_reader\_user) | The Redis CUS User (Reader) | `string` | n/a | yes |
| <a name="input_redis_cus_writer_password"></a> [redis\_cus\_writer\_password](#input\_redis\_cus\_writer\_password) | The Redis CUS Password (Writer) | `string` | n/a | yes |
| <a name="input_redis_cus_writer_user"></a> [redis\_cus\_writer\_user](#input\_redis\_cus\_writer\_user) | The Redis CUS User (Writer) | `string` | n/a | yes |
| <a name="input_reset_values"></a> [reset\_values](#input\_reset\_values) | Reset the values to the ones built into the chart. This will override any custom values and reuse\_values settings. | `bool` | `false` | no |
| <a name="input_resource_definitions"></a> [resource\_definitions](#input\_resource\_definitions) | Defines a list of definition of resources that belong to a service | <pre>map(object({<br/>    resource_block = optional(string)<br/>    istio_proxy_resources = optional(object({<br/>      limits = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>      requests = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>    }))<br/>    replicas = number<br/>  }))</pre> | `{}` | no |
| <a name="input_root_ca_certificate"></a> [root\_ca\_certificate](#input\_root\_ca\_certificate) | The LDAP Root CA Certificate | `string` | n/a | yes |
| <a name="input_sub_ca_certificate"></a> [sub\_ca\_certificate](#input\_sub\_ca\_certificate) | The LDAP Sub CA Certificate | `string` | n/a | yes |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | The namespace to deploy the application to | `string` | `"demis"` | no |
| <a name="input_ti_idp_client_name"></a> [ti\_idp\_client\_name](#input\_ti\_idp\_client\_name) | The client name for access the DEMIS Notification Portal over the Telematikinfrastruktur (TI) | `string` | `""` | no |
| <a name="input_ti_idp_hostname"></a> [ti\_idp\_hostname](#input\_ti\_idp\_hostname) | The Portal URL to access the DEMIS Notification Portal | `string` | `""` | no |
| <a name="input_ti_idp_redirect_uri"></a> [ti\_idp\_redirect\_uri](#input\_ti\_idp\_redirect\_uri) | The redirect uri to access the DEMIS Notification Portal over the Telematikinfrastruktur (TI) | `string` | `""` | no |
| <a name="input_ti_idp_return_sso_token"></a> [ti\_idp\_return\_sso\_token](#input\_ti\_idp\_return\_sso\_token) | Activate return sso token for access the DEMIS Notification Portal over the Telematikinfrastruktur (TI) | `bool` | `true` | no |
| <a name="input_ti_idp_server_url"></a> [ti\_idp\_server\_url](#input\_ti\_idp\_server\_url) | The server url for DEMIS Notification Portal over the Telematikinfrastruktur (TI) | `string` | `""` | no |
| <a name="input_tsl_download_endpoint"></a> [tsl\_download\_endpoint](#input\_tsl\_download\_endpoint) | Defines the TSL download endpoint for keycloak | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cus_enabled"></a> [cus\_enabled](#output\_cus\_enabled) | Whether the Certificate Update Service is enabled |
| <a name="output_cus_version"></a> [cus\_version](#output\_cus\_version) | The version of Certificate Update Service |
| <a name="output_kup_enabled"></a> [kup\_enabled](#output\_kup\_enabled) | Whether the Keycloak-User-Purger is enabled |
| <a name="output_kup_version"></a> [kup\_version](#output\_kup\_version) | The version of Keycloak-User-Purger |
| <a name="output_stage_configuration_data_name"></a> [stage\_configuration\_data\_name](#output\_stage\_configuration\_data\_name) | Name of the Stage Configuration Data |
| <a name="output_version_istio_routing_chart"></a> [version\_istio\_routing\_chart](#output\_version\_istio\_routing\_chart) | Version of the Istio Routing Chart being used |
| <a name="output_version_stage_configuration_data"></a> [version\_stage\_configuration\_data](#output\_version\_stage\_configuration\_data) | Version of the Stage Configuration Data |
<!-- END_TF_DOCS -->