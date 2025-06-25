<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [terraform_data.canary_profiles](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.destination_subsets](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.destination_subsets_canary](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.destination_subsets_main](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.main_profiles](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.profile_version_labels_canary](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.profile_version_labels_main](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.subset_name_canary](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.subset_name_main](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.version_canary](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.version_labels](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.version_labels_canary](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.version_labels_main](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.version_main](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_profile_snapshots"></a> [default\_profile\_snapshots](#input\_default\_profile\_snapshots) | The version of the FHIR Profile Snapshots to use for fallback | `string` | n/a | yes |
| <a name="input_deployment_information"></a> [deployment\_information](#input\_deployment\_information) | Deployment information for managing the main and optional canary version of the application | <pre>object({<br/>    main = object({<br/>      version  = string<br/>      weight   = number<br/>      profiles = optional(list(string), [])<br/>    })<br/>    canary = optional(object({<br/>      version  = optional(string)<br/>      weight   = optional(string)<br/>      profiles = optional(list(string))<br/>    }), {})<br/>  })</pre> | n/a | yes |
| <a name="input_is_canary"></a> [is\_canary](#input\_is\_canary) | Flag to indicate if the deployment is a canary. | `bool` | `false` | no |
| <a name="input_profile_type"></a> [profile\_type](#input\_profile\_type) | Profile types for the validation services. Allowed values are: fhir-profile-snapshots, igs-profile-snapshots, ars-profile-snapshots, demis-fhir-profile-snapshots, demis-igs-profile-snapshots, demis-ars-profile-snapshots | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_canary_profile_versions"></a> [canary\_profile\_versions](#output\_canary\_profile\_versions) | values for the canary profile versions |
| <a name="output_current_profile_versions"></a> [current\_profile\_versions](#output\_current\_profile\_versions) | values for the current profile versions depending on the is\_canary flag |
| <a name="output_destination_subsets"></a> [destination\_subsets](#output\_destination\_subsets) | values for the destination subsets |
| <a name="output_main_profile_versions"></a> [main\_profile\_versions](#output\_main\_profile\_versions) | values for the main profile versions |
| <a name="output_version_labels"></a> [version\_labels](#output\_version\_labels) | values for the version labels result for the main and canary deployments depending on the is\_canary flag |
| <a name="output_version_labels_canary"></a> [version\_labels\_canary](#output\_version\_labels\_canary) | values for the version labels for canary deployment |
| <a name="output_version_labels_main"></a> [version\_labels\_main](#output\_version\_labels\_main) | values for the version labels for main deployment |
<!-- END_TF_DOCS -->