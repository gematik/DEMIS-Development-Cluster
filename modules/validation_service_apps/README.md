<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0, < 4.0.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_validation_service"></a> [validation\_service](#module\_validation\_service) | ../helm_deployment | n/a |
| <a name="module_validation_service_legacy"></a> [validation\_service\_legacy](#module\_validation\_service\_legacy) | ../helm_deployment | n/a |
| <a name="module_validation_service_metadata"></a> [validation\_service\_metadata](#module\_validation\_service\_metadata) | ../fhir-profiles-metadata | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.istio](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_app_template_file"></a> [app\_template\_file](#input\_app\_template\_file) | Path to the application values template file for the Validation Service. If not provided, the default template will be used. | `string` | `""` | no |
| <a name="input_app_template_params"></a> [app\_template\_params](#input\_app\_template\_params) | Map of variables to be passed to the application values template for the Validation Service. This allows for dynamic configuration of the application-related Helm values based on user input or other variables. | `any` | `{}` | no |
| <a name="input_app_values_override"></a> [app\_values\_override](#input\_app\_values\_override) | Content of the application values override file for the Validation Service. If not provided, it will be ignored. | `string` | `""` | no |
| <a name="input_config_options"></a> [config\_options](#input\_config\_options) | Defines a list of ops flags to be bound in services | `map(map(string))` | `{}` | no |
| <a name="input_deployment_information"></a> [deployment\_information](#input\_deployment\_information) | Structure holding deployment information for the Helm Charts | <pre>object({<br/>    chart-name          = optional(string) # Optional, uses a different Helm Chart name than the application name<br/>    image-tag           = optional(string) # Optional, uses a different image tag for the deployment<br/>    deployment-strategy = string<br/>    enabled             = bool<br/>    main = object({<br/>      version  = string<br/>      weight   = number<br/>      profiles = optional(list(string))<br/>    })<br/>    canary = optional(object({<br/>      version  = optional(string)<br/>      weight   = optional(string)<br/>      profiles = optional(list(string))<br/>    }), {})<br/>  })</pre> | n/a | yes |
| <a name="input_external_template_directory"></a> [external\_template\_directory](#input\_external\_template\_directory) | Path to an external directory containing Helm values templates for the Validation Service | `string` | n/a | yes |
| <a name="input_feature_flags"></a> [feature\_flags](#input\_feature\_flags) | Defines a list of feature flags to be bound in services | `map(map(bool))` | `{}` | no |
| <a name="input_helm_release_settings"></a> [helm\_release\_settings](#input\_helm\_release\_settings) | Map of common Helm release settings to be applied to the Validation Service deployment. This can include settings such as 'atomic', 'timeout', 'wait', etc., which control the behavior of the Helm release process. | `map(string)` | n/a | yes |
| <a name="input_istio_template_file"></a> [istio\_template\_file](#input\_istio\_template\_file) | Path to the Istio values template file for the Validation Service. If not provided, the default template will be used. | `string` | `""` | no |
| <a name="input_istio_template_params"></a> [istio\_template\_params](#input\_istio\_template\_params) | Map of variables to be passed to the Istio values template for the Validation Service. This allows for dynamic configuration of the Istio-related Helm values based on user input or other variables. | `any` | `{}` | no |
| <a name="input_istio_values_override"></a> [istio\_values\_override](#input\_istio\_values\_override) | Content of the Istio values override file for the Validation Service. If not provided, it will be ignored. | `string` | `""` | no |
| <a name="input_local_template_directory"></a> [local\_template\_directory](#input\_local\_template\_directory) | Path to a local directory containing Helm values templates for the Validation Service | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Validation Service deployment | `string` | n/a | yes |
| <a name="input_package_type"></a> [package\_type](#input\_package\_type) | Profile types for the validation services. Allowed values are: fhir-profile-snapshots, igs-profile-snapshots, ars-profile-snapshots, are-profile-snapshots | `string` | n/a | yes |
| <a name="input_profile_provisioning_mode"></a> [profile\_provisioning\_mode](#input\_profile\_provisioning\_mode) | Provisioning mode for the FHIR Profiles services. Allowed values are: dedicated, distributed, combined | `string` | n/a | yes |
| <a name="input_resource_definitions"></a> [resource\_definitions](#input\_resource\_definitions) | Defines a list of definition of resources that belong to a service | <pre>map(object({<br/>    resource_block = optional(string)<br/>    istio_proxy_resources = optional(object({<br/>      limits   = optional(map(string))<br/>      requests = optional(map(string))<br/>    }))<br/>    replicas = number<br/>  }))</pre> | `{}` | no |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | The namespace to deploy the application to | `string` | n/a | yes |
| <a name="input_timeout_retries"></a> [timeout\_retries](#input\_timeout\_retries) | Defines retry and timeout override configurations per service. Each definition must include a service name and can optionally include timeout and retry settings. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_profile_metadata"></a> [profile\_metadata](#output\_profile\_metadata) | The metadata of the FHIR profiles used for the Validation Service, including their versions and the destination subsets for Istio routing. |
<!-- END_TF_DOCS -->