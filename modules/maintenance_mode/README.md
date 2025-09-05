<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [terraform_data.set_maintenance_mode](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.update_services](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activate_maintenance_mode"></a> [activate\_maintenance\_mode](#input\_activate\_maintenance\_mode) | Boolean value whether to activate (true) or deactivate (false) the maintenance mode | `bool` | n/a | yes |
| <a name="input_deployment_information"></a> [deployment\_information](#input\_deployment\_information) | Structure holding deployment information for the Helm Charts | <pre>map(object({<br/>    chart-name          = optional(string) # Optional, uses a different Helm Chart name than the application name<br/>    deployment-strategy = string<br/>    enabled             = bool<br/>    main = object({<br/>      version = string<br/>      weight  = number<br/>    })<br/>    canary = optional(object({<br/>      version = optional(string)<br/>      weight  = optional(string)<br/>    }), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to the kubeconfig file for the cluster | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_maintenance_mode_status"></a> [maintenance\_mode\_status](#output\_maintenance\_mode\_status) | new status of the maintenance mode |
<!-- END_TF_DOCS -->