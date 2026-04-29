# applications

Module responsible for deploying the ARE Services Helm Charts in a Kubernetes Cluster.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0, < 4.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0.0, < 4.0.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_are_notification_processing_service"></a> [are\_notification\_processing\_service](#module\_are\_notification\_processing\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_http_timeouts_retries"></a> [http\_timeouts\_retries](#module\_http\_timeouts\_retries) | ../../modules/http_timeouts_retries | n/a |
| <a name="module_notification_are_gateway"></a> [notification\_are\_gateway](#module\_notification\_are\_gateway) | ../../modules/helm_deployment | n/a |
| <a name="module_portal_are"></a> [portal\_are](#module\_portal\_are) | ../../modules/helm_deployment | n/a |
| <a name="module_validation_service_are"></a> [validation\_service\_are](#module\_validation\_service\_are) | ../../modules/helm_deployment | n/a |
| <a name="module_validation_service_are_metadata"></a> [validation\_service\_are\_metadata](#module\_validation\_service\_are\_metadata) | ../../modules/fhir-profiles-metadata | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.validation_service](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_secret_v1.redis_cus_reader_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_auth_hostname"></a> [auth\_hostname](#input\_auth\_hostname) | The Keycloak Issuer URL to be used for the JSON Web Token (JWT) validation | `string` | `"auth"` | no |
| <a name="input_cluster_gateway"></a> [cluster\_gateway](#input\_cluster\_gateway) | Defines the Istio Cluster Gateway to be used | `string` | `"mesh/demis-core-gateway"` | no |
| <a name="input_config_options"></a> [config\_options](#input\_config\_options) | Defines a list of ops flags to be bound in services | `map(map(string))` | `{}` | no |
| <a name="input_context_path"></a> [context\_path](#input\_context\_path) | The context path for reaching the DEMIS Services externally | `string` | `""` | no |
| <a name="input_core_hostname"></a> [core\_hostname](#input\_core\_hostname) | The URL to access the DEMIS Core API | `string` | `""` | no |
| <a name="input_debug_enabled"></a> [debug\_enabled](#input\_debug\_enabled) | Defines if the backend Java Services must be started in Debug Mode | `bool` | `false` | no |
| <a name="input_deployment_information"></a> [deployment\_information](#input\_deployment\_information) | Structure holding deployment information for the Helm Charts | <pre>map(object({<br/>    chart-name          = optional(string) # Optional, uses a different Helm Chart name than the application name<br/>    image-tag           = optional(string) # Optional, uses a different image tag for the deployment<br/>    deployment-strategy = string<br/>    enabled             = bool<br/>    main = object({<br/>      version  = string<br/>      weight   = number<br/>      profiles = optional(list(string))<br/>    })<br/>    canary = optional(object({<br/>      version  = optional(string)<br/>      weight   = optional(string)<br/>      profiles = optional(list(string))<br/>    }), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_deployment_timeout"></a> [deployment\_timeout](#input\_deployment\_timeout) | Timeout for the deployment in minutes | `number` | `600` | no |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | The docker registry to use for the application | `string` | n/a | yes |
| <a name="input_external_chart_path"></a> [external\_chart\_path](#input\_external\_chart\_path) | The path to the stage-dependent Helm Chart Values. | `string` | n/a | yes |
| <a name="input_external_routing_configurations"></a> [external\_routing\_configurations](#input\_external\_routing\_configurations) | Defines the rendered Istio routing rules for the application, generated from the input mapping and the template variables. The structure is a map where the keys are service names and the values are lists of routing rules associated with each service. | `object({ rules = any })` | <pre>{<br/>  "rules": {}<br/>}</pre> | no |
| <a name="input_feature_flags"></a> [feature\_flags](#input\_feature\_flags) | Defines a list of feature flags to be bound in services | `map(map(bool))` | `{}` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | The helm repository to use for the application | `string` | n/a | yes |
| <a name="input_helm_repository_password"></a> [helm\_repository\_password](#input\_helm\_repository\_password) | The password for the helm repository | `string` | `""` | no |
| <a name="input_helm_repository_username"></a> [helm\_repository\_username](#input\_helm\_repository\_username) | The username for the helm repository | `string` | `""` | no |
| <a name="input_istio_enabled"></a> [istio\_enabled](#input\_istio\_enabled) | Enable istio for the application | `bool` | `true` | no |
| <a name="input_istio_proxy_default_resources"></a> [istio\_proxy\_default\_resources](#input\_istio\_proxy\_default\_resources) | Default values for istio proxy resource requests and limits | <pre>object({<br/>    limits = object({<br/>      cpu    = optional(string)<br/>      memory = string<br/>    })<br/>    requests = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_maintenance_mode_trigger"></a> [maintenance\_mode\_trigger](#input\_maintenance\_mode\_trigger) | Output from module.activate\_maintenance\_mode that establishes deploy ordering without known-after-apply propagation. | `string` | `""` | no |
| <a name="input_meldung_hostname"></a> [meldung\_hostname](#input\_meldung\_hostname) | The URL for accessing the DEMIS Notification Portal over Internet | `string` | `"meldung"` | no |
| <a name="input_portal_hostname"></a> [portal\_hostname](#input\_portal\_hostname) | The URL for accessing the DEMIS Notification Portal over Telematikinfrastruktur (TI) | `string` | `"portal"` | no |
| <a name="input_profile_provisioning_mode_vs_are"></a> [profile\_provisioning\_mode\_vs\_are](#input\_profile\_provisioning\_mode\_vs\_are) | Provisioning mode for the FHIR Profiles services. Allowed values are: dedicated, distributed, combined | `string` | `null` | no |
| <a name="input_project_feature_flags"></a> [project\_feature\_flags](#input\_project\_feature\_flags) | Map of feature flags to enable or disable specific features in the DEMIS deployment. The keys are the names of the feature flags, and the values are booleans indicating whether the feature is enabled (true) or disabled (false). | `map(bool)` | `{}` | no |
| <a name="input_pull_secrets"></a> [pull\_secrets](#input\_pull\_secrets) | The list of pull secrets to be used for downloading Docker Images | `list(string)` | `[]` | no |
| <a name="input_pvc_trigger"></a> [pvc\_trigger](#input\_pvc\_trigger) | List of PVC names from module.persistent\_volume\_claims that establishes deploy ordering without known-after-apply propagation. | `list(string)` | `[]` | no |
| <a name="input_redis_cus_reader_password"></a> [redis\_cus\_reader\_password](#input\_redis\_cus\_reader\_password) | The Redis CUS Password (Reader) | `string` | n/a | yes |
| <a name="input_redis_cus_reader_user"></a> [redis\_cus\_reader\_user](#input\_redis\_cus\_reader\_user) | The Redis CUS User (Reader) | `string` | n/a | yes |
| <a name="input_reset_values"></a> [reset\_values](#input\_reset\_values) | Reset the values to the ones built into the chart. This will override any custom values and reuse\_values settings. | `bool` | `false` | no |
| <a name="input_resource_definitions"></a> [resource\_definitions](#input\_resource\_definitions) | Defines a list of definition of resources that belong to a service | <pre>map(object({<br/>    resource_block = optional(string)<br/>    istio_proxy_resources = optional(object({<br/>      limits = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>      requests = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>    }))<br/>    replicas = number<br/>  }))</pre> | `{}` | no |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | The namespace to deploy the application to | `string` | `"are"` | no |
| <a name="input_timeout_retry_overrides"></a> [timeout\_retry\_overrides](#input\_timeout\_retry\_overrides) | Defines retry and timeout configurations per service. Each definition must include a service name and can optionally include timeout and retry settings. | <pre>list(object({<br/>    service = string<br/>    timeout = optional(string)<br/>    retries = optional(object({<br/>      enable        = optional(bool)<br/>      attempts      = optional(number)<br/>      perTryTimeout = optional(string)<br/>      retryOn       = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_version_istio_routing_chart"></a> [version\_istio\_routing\_chart](#output\_version\_istio\_routing\_chart) | Version of the Istio Routing Chart being used |
<!-- END_TF_DOCS -->