# applications

Module responsible for deploying the DEMIS Services Helm Charts in a Kubernetes Cluster.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_http_timeouts_retries"></a> [http\_timeouts\_retries](#module\_http\_timeouts\_retries) | ../../modules/http_timeouts_retries | n/a |
| <a name="module_service_demo"></a> [service\_demo](#module\_service\_demo) | ../../modules/helm_deployment | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_gateway"></a> [cluster\_gateway](#input\_cluster\_gateway) | Defines the Istio Cluster Gateway to be used | `string` | `"mesh/demis-core-gateway"` | no |
| <a name="input_config_options"></a> [config\_options](#input\_config\_options) | Defines a list of ops flags to be bound in services | `map(map(string))` | `{}` | no |
| <a name="input_context_path"></a> [context\_path](#input\_context\_path) | The context path for reaching the DEMIS Services externally | `string` | `""` | no |
| <a name="input_core_hostname"></a> [core\_hostname](#input\_core\_hostname) | The URL to access the DEMIS Core API | `string` | `""` | no |
| <a name="input_debug_enabled"></a> [debug\_enabled](#input\_debug\_enabled) | Defines if the backend Java Services must be started in Debug Mode | `bool` | `false` | no |
| <a name="input_deployment_information"></a> [deployment\_information](#input\_deployment\_information) | Structure holding deployment information for the Helm Charts | <pre>map(object({<br/>    chart-name          = optional(string) # Optional, uses a different Helm Chart name than the application name<br/>    image-tag           = optional(string) # Optional, uses a different image tag for the deployment<br/>    deployment-strategy = string<br/>    enabled             = bool<br/>    main = object({<br/>      version  = string<br/>      weight   = number<br/>      profiles = optional(list(string))<br/>    })<br/>    canary = optional(object({<br/>      version  = optional(string)<br/>      weight   = optional(string)<br/>      profiles = optional(list(string))<br/>    }), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | The docker registry to use for the application | `string` | n/a | yes |
| <a name="input_external_chart_path"></a> [external\_chart\_path](#input\_external\_chart\_path) | The path to the stage-dependent Helm Chart Values. | `string` | n/a | yes |
| <a name="input_feature_flags"></a> [feature\_flags](#input\_feature\_flags) | Defines a list of feature flags to be bound in services | `map(map(bool))` | `{}` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | The helm repository to use for the application | `string` | n/a | yes |
| <a name="input_helm_repository_password"></a> [helm\_repository\_password](#input\_helm\_repository\_password) | The password for the helm repository | `string` | `""` | no |
| <a name="input_helm_repository_username"></a> [helm\_repository\_username](#input\_helm\_repository\_username) | The username for the helm repository | `string` | `""` | no |
| <a name="input_istio_enabled"></a> [istio\_enabled](#input\_istio\_enabled) | Enable istio for the application | `bool` | `true` | no |
| <a name="input_istio_proxy_default_resources"></a> [istio\_proxy\_default\_resources](#input\_istio\_proxy\_default\_resources) | Default values for istio proxy resource requests and limits | <pre>object({<br/>    limits = object({<br/>      cpu    = optional(string)<br/>      memory = string<br/>    })<br/>    requests = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_meldung_hostname"></a> [meldung\_hostname](#input\_meldung\_hostname) | The URL for accessing the DEMIS Notification Portal over Internet | `string` | `"meldung"` | no |
| <a name="input_portal_hostname"></a> [portal\_hostname](#input\_portal\_hostname) | The URL for accessing the DEMIS Notification Portal over Telematikinfrastruktur (TI) | `string` | `"portal"` | no |
| <a name="input_pull_secrets"></a> [pull\_secrets](#input\_pull\_secrets) | The list of pull secrets to be used for downloading Docker Images | `list(string)` | `[]` | no |
| <a name="input_reset_values"></a> [reset\_values](#input\_reset\_values) | Reset the values to the ones built into the chart. This will override any custom values and reuse\_values settings. | `bool` | `false` | no |
| <a name="input_resource_definitions"></a> [resource\_definitions](#input\_resource\_definitions) | Defines a list of definition of resources that belong to a service | <pre>map(object({<br/>    resource_block = optional(string)<br/>    istio_proxy_resources = optional(object({<br/>      limits = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>      requests = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>    }))<br/>    replicas = number<br/>  }))</pre> | `{}` | no |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | The namespace to deploy the application to | `string` | `"demis"` | no |
| <a name="input_timeout_retry_overrides"></a> [timeout\_retry\_overrides](#input\_timeout\_retry\_overrides) | Defines retry and timeout configurations per service. Each definition must include a service name and can optionally include timeout and retry settings. | <pre>list(object({<br/>    service = string<br/>    timeout = optional(string)<br/>    retries = optional(object({<br/>      enable        = optional(bool)<br/>      attempts      = optional(number)<br/>      perTryTimeout = optional(string)<br/>      retryOn       = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_version_istio_routing_chart"></a> [version\_istio\_routing\_chart](#output\_version\_istio\_routing\_chart) | Version of the Istio Routing Chart being used |
<!-- END_TF_DOCS -->