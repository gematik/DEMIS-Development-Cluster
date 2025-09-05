<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.0.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.policy_reporter](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | The Helm Chart Version for Kyverno Policy Reporter | `string` | `"2.24.1"` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | The Helm Chart Repository for Kyverno Policy Reporter | `string` | `"https://kyverno.github.io/policy-reporter"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where to install Kyverno Policy Reporter | `string` | `"security"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_chart_version"></a> [chart\_version](#output\_chart\_version) | Kyverno Helm Chart Version |
| <a name="output_helm_repository"></a> [helm\_repository](#output\_helm\_repository) | Kyverno Helm Repository |
<!-- END_TF_DOCS -->