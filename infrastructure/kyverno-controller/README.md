<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0, < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.kyverno](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admissioncontroller_replicas"></a> [admissioncontroller\_replicas](#input\_admissioncontroller\_replicas) | setting replicas of admission controller | `number` | `3` | no |
| <a name="input_backgroundcontroller_replicas"></a> [backgroundcontroller\_replicas](#input\_backgroundcontroller\_replicas) | setting replicas of background controller | `number` | `2` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | The Helm Chart Version for Kyverno | `string` | `"3.5.1"` | no |
| <a name="input_cleanupcontroller_replicas"></a> [cleanupcontroller\_replicas](#input\_cleanupcontroller\_replicas) | setting replicas of cleanup controller | `number` | `2` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | The Helm Chart Repository for Kyverno | `string` | `"https://kyverno.github.io/kyverno/"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where to install Kyverno | `string` | `"kyverno"` | no |
| <a name="input_pull_secrets"></a> [pull\_secrets](#input\_pull\_secrets) | The list of pull secrets to be used for downloading Docker Images | `list(string)` | `[]` | no |
| <a name="input_reportscontroller_replicas"></a> [reportscontroller\_replicas](#input\_reportscontroller\_replicas) | setting replicas of reports controller | `number` | `2` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_chart_version"></a> [chart\_version](#output\_chart\_version) | Kyverno Helm Chart Version |
| <a name="output_helm_repository"></a> [helm\_repository](#output\_helm\_repository) | Kyverno Helm Repository |
<!-- END_TF_DOCS -->