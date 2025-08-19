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
| [terraform_data.main_profiles](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.subsets_canary](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.subsets_main](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_profile_snapshots"></a> [default\_profile\_snapshots](#input\_default\_profile\_snapshots) | The version of the FHIR Profile Snapshots to use for fallback | `string` | n/a | yes |
| <a name="input_deployment_information"></a> [deployment\_information](#input\_deployment\_information) | Deployment information for managing the main and optional canary version of the application | <pre>object({<br/>    main = object({<br/>      version  = string<br/>      weight   = number<br/>      profiles = optional(list(string), [])<br/>    })<br/>    canary = optional(object({<br/>      version  = optional(string)<br/>      weight   = optional(string)<br/>      profiles = optional(list(string))<br/>    }), {})<br/>  })</pre> | n/a | yes |
| <a name="input_profile_type"></a> [profile\_type](#input\_profile\_type) | Profile types for the validation services. Allowed values are: fhir-profile-snapshots, igs-profile-snapshots, ars-profile-snapshots | `string` | n/a | yes |
| <a name="input_provisioning_mode"></a> [provisioning\_mode](#input\_provisioning\_mode) | Provisioning mode for the FHIR Profiles Metadata. Allowed values are: dedicated, distributed, combined | `string` | `"dedicated"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_canary_profile_versions"></a> [canary\_profile\_versions](#output\_canary\_profile\_versions) | values for the canary profile versions |
| <a name="output_current_profile_versions"></a> [current\_profile\_versions](#output\_current\_profile\_versions) | values for the current profile versions depending on the is\_canary flag |
| <a name="output_destination_subsets"></a> [destination\_subsets](#output\_destination\_subsets) | values for the destination subsets |
| <a name="output_main_profile_versions"></a> [main\_profile\_versions](#output\_main\_profile\_versions) | values for the main profile versions |
<!-- END_TF_DOCS -->