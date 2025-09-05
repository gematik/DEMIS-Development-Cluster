# namespace

Module responsible for creating a new Kubernetes Namespace, with support for custom labels and annotations, including a switch for enabling the Istio Sidecar Injection.

## Usage

In your Project, create a new `module` Block and pass the desired information:

```hcl
module "demis_namespace" {
    source = "/path/to/this/module"

    name = "your-namespace-name"
    enable_istio_injection = true # to enable the Istio Sidecar injection, default is false
    # Optional
    labels = {
      "my-label-key": "my-label-value"
    }
    # Optional
    annotations = {
      "my-annotation-key": "my-annotation-value"
    }
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
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.35.0, < 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_annotations"></a> [annotations](#input\_annotations) | The annotations to apply to the Namespace | `map(string)` | `{}` | no |
| <a name="input_enable_istio_injection"></a> [enable\_istio\_injection](#input\_enable\_istio\_injection) | Enable Istio Sidecar Injection for the Namespace | `bool` | `false` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | The labels to apply to the Namespace | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Namespace that should be created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_annotations"></a> [annotations](#output\_annotations) | Prints the annotations of the Namespace |
| <a name="output_labels"></a> [labels](#output\_labels) | Prints the labels of the Namespace |
| <a name="output_name"></a> [name](#output\_name) | Prints the name of the Namespace |
<!-- END_TF_DOCS -->