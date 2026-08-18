# resources

Module responsible for organizing http request timeouts and retries per service, so these can be used to inject values in Helm Charts.

## Usage

In your Project, create a new `module` Block and pass the desired information:

```hcl
module "timeout_retry_configurations" {
  source = "/path/to/this/module"
  # pass the resource definitions to the module
  timeout_retry_definitions = [
    {
      service = "service1"
      timeout = "2s"
      retries = {
        enable        = true,
        attempts      = 2,
        perTryTimeout = "2s",
        retryOn       = "connect-failure,refused-stream,unavailable,cancelled"
      }
    }
  ]
}
```
For more information on how to configure the inputs, please refer to the istio docs for [timeouts](https://istio.io/latest/docs/reference/config/networking/virtual-service/#HTTPRoute-timeout) and [retries](https://istio.io/latest/docs/reference/config/networking/virtual-service/#HTTPRoute-retries).


## Tests

The module contains unit tests that can be executed with the following command: 

```sh
tofu test
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_custom_timeout_retry"></a> [custom\_timeout\_retry](#input\_custom\_timeout\_retry) | Defines retry and timeout default configurations per service. Each definition must include a service name and can optionally include timeout and retry settings. | <pre>list(object({<br/>    service = string<br/>    timeout = optional(string)<br/>    retries = optional(object({<br/>      attempts      = optional(number)<br/>      perTryTimeout = optional(string)<br/>      retryOn       = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_no_retries_services"></a> [no\_retries\_services](#input\_no\_retries\_services) | List of service names that should receive the built-in no-retries default (0 attempts). Explicit custom\_timeout\_retry and timeout\_retry\_overrides take precedence. | `list(string)` | `[]` | no |
| <a name="input_service_names"></a> [service\_names](#input\_service\_names) | List of all deployed service names (typically keys(deployment\_information)). Every service in this list that has no explicit no\_retries\_services, custom\_timeout\_retry or timeout\_retry\_overrides configuration receives the built-in common default (timeout 5s, 1 attempt, perTryTimeout 5s). | `list(string)` | `[]` | no |
| <a name="input_timeout_retry_overrides"></a> [timeout\_retry\_overrides](#input\_timeout\_retry\_overrides) | Defines retry and timeout override configurations per service. Each definition must include a service name and can optionally include timeout and retry settings. | <pre>list(object({<br/>    service = string<br/>    timeout = optional(string)<br/>    retries = optional(object({<br/>      attempts      = optional(number)<br/>      perTryTimeout = optional(string)<br/>      retryOn       = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_service_timeout_retry_definitions"></a> [service\_timeout\_retry\_definitions](#output\_service\_timeout\_retry\_definitions) | Map containing all the timeout and retry definitions, grouped by service |
<!-- END_TF_DOCS -->