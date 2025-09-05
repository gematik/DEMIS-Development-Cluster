# resources

Module responsible for ordering Resources Definitions (CPU/Memory Limits and Requests, Replica Counts) per service, so these can be used to inject values in Helm Charts.

## Usage

In your Project, create a new `module` Block and pass the desired information:

```hcl
module "application_resources" {
  source = "/path/to/this/module"
  # pass the resource definitions to the module
  resource_definitions = [
    {
      service = "service1"
      replicas = 1
      resources = {
        limits = {
          cpu = "100m"
          memory = "256Mi"
        }
        requests = {
          cpu = "100m"
          memory = "256Mi"
        }
      }
    }
  ]
}
```

## Tests

The module contains unit tests that can be executed with the following command: 

```sh
tofu test
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_definitions"></a> [resource\_definitions](#input\_resource\_definitions) | Defines a list of definition of resources that belong to a service | <pre>list(object({<br/>    service  = string<br/>    replicas = number<br/>    resources = optional(object({<br/>      limits = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>      requests = optional(object({<br/>        cpu    = optional(string)<br/>        memory = optional(string)<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_resource_definitions"></a> [service\_resource\_definitions](#output\_service\_resource\_definitions) | Map containing all the resources definitions, grouped by service |
<!-- END_TF_DOCS -->