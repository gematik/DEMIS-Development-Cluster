<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0, < 4.0.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_namespace"></a> [namespace](#module\_namespace) | ../../modules/namespace | n/a |
| <a name="module_pull_secrets"></a> [pull\_secrets](#module\_pull\_secrets) | ../../modules/pull_secret | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.kyverno](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_admissioncontroller_replicas"></a> [admissioncontroller\_replicas](#input\_admissioncontroller\_replicas) | setting replicas of admission controller | `number` | `3` | no |
| <a name="input_backgroundcontroller_replicas"></a> [backgroundcontroller\_replicas](#input\_backgroundcontroller\_replicas) | setting replicas of background controller | `number` | `2` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | The Helm Chart Version for Kyverno | `string` | `"3.5.3"` | no |
| <a name="input_cleanupcontroller_replicas"></a> [cleanupcontroller\_replicas](#input\_cleanupcontroller\_replicas) | setting replicas of cleanup controller | `number` | `2` | no |
| <a name="input_docker_pull_secrets"></a> [docker\_pull\_secrets](#input\_docker\_pull\_secrets) | Pull Secrets for the Kyverno images (see docker\_pull\_secrets of the infrastructure) | <pre>list(object({<br/>    name          = string<br/>    registry      = string<br/>    user_name     = string<br/>    user_email    = string<br/>    user_password = string<br/>    password_type = string<br/>  }))</pre> | `[]` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Deploys Kyverno; namespace and pull secrets are created in any case | `bool` | `true` | no |
| <a name="input_google_cloud_access_token"></a> [google\_cloud\_access\_token](#input\_google\_cloud\_access\_token) | Access Token used for the Pull Secrets with password\_type 'token' | `string` | `""` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | The Helm Chart Repository for Kyverno | `string` | `"https://kyverno.github.io/kyverno/"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where to install Kyverno | `string` | `"kyverno"` | no |
| <a name="input_reportscontroller_replicas"></a> [reportscontroller\_replicas](#input\_reportscontroller\_replicas) | setting replicas of reports controller | `number` | `2` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_chart_version"></a> [chart\_version](#output\_chart\_version) | Kyverno Helm Chart Version |
| <a name="output_helm_repository"></a> [helm\_repository](#output\_helm\_repository) | Kyverno Helm Repository |
<!-- END_TF_DOCS -->
