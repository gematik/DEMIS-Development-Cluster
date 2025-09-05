# persistence_volume_claim

Module responsible for creating one or more Kubernetes PersistenceVolumeClaims, with support for custom labels and annotations.

## Usage

In your Project, create a new `module` Block and pass the desired information:

```hcl
module "my_pvc" {
    source = "/path/to/this/module"

    namespace     = "demis"
    name          = "keycloak-volume-claim"
    storage_class = "standard"
    capacity      = "20Mi"
    access_mode   = "ReadWriteOnce"
    # Optional
    labels = {
      "my-label" : "my-value"
    }
    # Optional
    annotations = {   
      "my-annotation" : "my-value"
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
| [kubernetes_persistent_volume_claim_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_mode"></a> [access\_mode](#input\_access\_mode) | The Access Mode of the Persistence Volume Claim | `string` | n/a | yes |
| <a name="input_annotations"></a> [annotations](#input\_annotations) | The Annotations to apply to the Persistence Volume Claim | `map(string)` | `{}` | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | The Capacity of the Persistence Volume Claim | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | The Labels to apply to the Persistence Volume Claim | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | The Name of the Pull Secret | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The name of the Namespace where the Persistence Volume Claim will be created | `string` | n/a | yes |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | The Storage Class to use for the Persistence Volume Claim | `string` | n/a | yes |
| <a name="input_wait_until_bound"></a> [wait\_until\_bound](#input\_wait\_until\_bound) | Wait until the Persistence Volume Claim is bound by some Pod. Default is false. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_metadata"></a> [metadata](#output\_metadata) | Prints the Metadata Information of the created Kubernetes Persistence Volume Claim |
<!-- END_TF_DOCS -->
