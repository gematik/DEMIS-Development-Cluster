<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | 2.3.5 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_global_template_variables"></a> [global\_template\_variables](#input\_global\_template\_variables) | Additional global variables for template substitution, provided as a map. | `map(string)` | `{}` | no |
| <a name="input_input_mapping_path"></a> [input\_mapping\_path](#input\_input\_mapping\_path) | Path to the traffic routes template YAML file. | `string` | n/a | yes |
| <a name="input_python_interpreter"></a> [python\_interpreter](#input\_python\_interpreter) | Python interpreter to pass as the first argument to the module's Python wrapper. | `string` | `"python3"` | no |
| <a name="input_service_list"></a> [service\_list](#input\_service\_list) | List of services to generate rules for. If empty, rules will be generated for all services in the input mapping. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_rules"></a> [rules](#output\_rules) | Rendered Istio rules as a Terraform object. |
<!-- END_TF_DOCS -->

