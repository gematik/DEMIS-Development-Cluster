# namespace_quota

Module responsible for creating a Kubernetes ResourceQuota for a given Namespace. Supports configuring CPU and memory limits and requests. The quota is only created when the `resource_quota` variable is set (not `null`).

## Usage

In your Project, create a new `module` Block and pass the desired information:

```hcl
module "demis_namespace_quota" {
    source = "/path/to/this/module"

    namespace = module.demis_namespace.name

    resource_quota = {
      limits_cpu     = "4"
      limits_memory  = "8Gi"
      # Optional: can be extended with requests
      # requests_cpu    = "2"
      # requests_memory = "4Gi"
    }
}
```

To skip quota creation, either omit the `resource_quota` variable or set it to `null`:

```hcl
module "mesh_namespace_quota" {
    source = "/path/to/this/module"

    namespace      = module.mesh_namespace.name
    resource_quota = null
}
```

## Variables

| Name | Type | Description | Default |
|------|------|-------------|---------|
| `namespace` | `string` | The Namespace to apply the ResourceQuota to | - |
| `resource_quota` | `object` | Quota configuration with optional fields: `limits_cpu`, `limits_memory`, `requests_cpu`, `requests_memory` | `null` |

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
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0.0, < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_resource_quota_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/resource_quota_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The name of the Namespace to apply the ResourceQuota to | `string` | n/a | yes |
| <a name="input_resource_quota"></a> [resource\_quota](#input\_resource\_quota) | Resource quota configuration for the Namespace. Set to null to skip quota creation. | <pre>object({<br/>    limits_cpu      = optional(string)<br/>    limits_memory   = optional(string)<br/>    requests_cpu    = optional(string)<br/>    requests_memory = optional(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_quota_name"></a> [resource\_quota\_name](#output\_resource\_quota\_name) | The name of the created ResourceQuota, or null if none was created |
<!-- END_TF_DOCS -->