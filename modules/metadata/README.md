# metadata

Module responsible for creating metadata tags that can be used across a Terraform/OpenTofu project.

## Usage

In your Project, create a new `module` Block and pass the desired information:

```hcl
module "demis_metadata" {
    source = "/path/to/this/module"

    name              = "demis"
    cluster           = "adesso-prod" # if cluster is "local", then the content of region is ignored
    region            = "fra"
    component         = "pvc"
    application       = "postgres"
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
| <a name="input_application"></a> [application](#input\_application) | Application name | `string` | n/a | yes |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Cluster name | `string` | n/a | yes |
| <a name="input_component"></a> [component](#input\_component) | Component name (e.g., web, api, db) | `string` | n/a | yes |
| <a name="input_organisation_name"></a> [organisation\_name](#input\_organisation\_name) | Organisation name | `string` | `"gematik_GmbH"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_name"></a> [resource\_name](#output\_resource\_name) | Standardized resource name |
| <a name="output_stage"></a> [stage](#output\_stage) | Standandized stage name |
| <a name="output_tags"></a> [tags](#output\_tags) | Standardized set of tags for all resources |
<!-- END_TF_DOCS -->