# security

Module to deploy the security tools (Trivy, Falco, Kyverno Policy Reporter) into their own namespace.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_falco"></a> [falco](#module\_falco) | ./falco | n/a |
| <a name="module_metadata"></a> [metadata](#module\_metadata) | ../../modules/metadata | n/a |
| <a name="module_namespace"></a> [namespace](#module\_namespace) | ../../modules/namespace | n/a |
| <a name="module_policy_reporter"></a> [policy\_reporter](#module\_policy\_reporter) | ./policy-reporter | n/a |
| <a name="module_trivy"></a> [trivy](#module\_trivy) | ./trivy | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_region"></a> [cluster\_region](#input\_cluster\_region) | Region of the cluster, used for the namespace labels | `string` | n/a | yes |
| <a name="input_falco_chart_version"></a> [falco\_chart\_version](#input\_falco\_chart\_version) | The version of the Falco Helm Chart | `string` | `"9.2.0"` | no |
| <a name="input_falco_driver_kind"></a> [falco\_driver\_kind](#input\_falco\_driver\_kind) | Falco driver kind | `string` | `"auto"` | no |
| <a name="input_falco_enabled"></a> [falco\_enabled](#input\_falco\_enabled) | Deploys Falco | `bool` | `false` | no |
| <a name="input_falco_falcosidekick_enabled"></a> [falco\_falcosidekick\_enabled](#input\_falco\_falcosidekick\_enabled) | Enables Falcosidekick | `bool` | `false` | no |
| <a name="input_falco_falcosidekick_ui_enabled"></a> [falco\_falcosidekick\_ui\_enabled](#input\_falco\_falcosidekick\_ui\_enabled) | Enables the Falcosidekick UI | `bool` | `false` | no |
| <a name="input_falco_helm_repository"></a> [falco\_helm\_repository](#input\_falco\_helm\_repository) | Falco Helm Chart Repository URL or repository name, null uses the module default | `string` | `null` | no |
| <a name="input_falco_kubernetes_meta_collector"></a> [falco\_kubernetes\_meta\_collector](#input\_falco\_kubernetes\_meta\_collector) | Enables the Kubernetes metadata collector of Falco | `bool` | `true` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace that is created for the security services (Trivy, Falco, Policy Reporter) | `string` | `"security"` | no |
| <a name="input_policy_reporter_chart_version"></a> [policy\_reporter\_chart\_version](#input\_policy\_reporter\_chart\_version) | The version of the Policy Reporter Helm Chart | `string` | `"3.7.2"` | no |
| <a name="input_policy_reporter_enabled"></a> [policy\_reporter\_enabled](#input\_policy\_reporter\_enabled) | Deploys the Kyverno Policy Reporter | `bool` | `false` | no |
| <a name="input_policy_reporter_helm_repository"></a> [policy\_reporter\_helm\_repository](#input\_policy\_reporter\_helm\_repository) | Policy Reporter Helm Chart Repository URL or repository name, null uses the module default | `string` | `null` | no |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | Name of the stage, used for the namespace labels | `string` | n/a | yes |
| <a name="input_trivy_additional_report_fields"></a> [trivy\_additional\_report\_fields](#input\_trivy\_additional\_report\_fields) | Additional fields of the Trivy reports | `string` | `"Description,Links,CVSS,Target,Class,PackagePath,PackageType"` | no |
| <a name="input_trivy_chart_version"></a> [trivy\_chart\_version](#input\_trivy\_chart\_version) | The version of the Trivy Helm Chart | `string` | `"0.23.3"` | no |
| <a name="input_trivy_cron_job_schedule"></a> [trivy\_cron\_job\_schedule](#input\_trivy\_cron\_job\_schedule) | Cron schedule of the Trivy scans | `string` | `"0 */6 * * *"` | no |
| <a name="input_trivy_enabled"></a> [trivy\_enabled](#input\_trivy\_enabled) | Deploys Trivy | `bool` | `false` | no |
| <a name="input_trivy_helm_repository"></a> [trivy\_helm\_repository](#input\_trivy\_helm\_repository) | Trivy Helm Chart Repository URL or repository name, null uses the module default | `string` | `null` | no |
| <a name="input_trivy_ignore_unfixed"></a> [trivy\_ignore\_unfixed](#input\_trivy\_ignore\_unfixed) | Ignores vulnerabilities without a fix | `bool` | `false` | no |
| <a name="input_trivy_private_registry_secret_names"></a> [trivy\_private\_registry\_secret\_names](#input\_trivy\_private\_registry\_secret\_names) | Namespace and comma separated tokens for private registries without imagePullSecrets | <pre>list(object({<br/>    namespace = string<br/>    token     = string<br/>  }))</pre> | `[]` | no |
| <a name="input_trivy_scan_jobs_limit"></a> [trivy\_scan\_jobs\_limit](#input\_trivy\_scan\_jobs\_limit) | Maximum number of parallel Trivy scan jobs | `string` | `"3"` | no |
| <a name="input_trivy_scan_namespaces"></a> [trivy\_scan\_namespaces](#input\_trivy\_scan\_namespaces) | Namespaces scanned by Trivy | `string` | `"demis"` | no |
| <a name="input_trivy_severity_levels"></a> [trivy\_severity\_levels](#input\_trivy\_severity\_levels) | Severity levels reported by Trivy | `string` | `"UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL"` | no |
| <a name="input_trivy_use_less_resources"></a> [trivy\_use\_less\_resources](#input\_trivy\_use\_less\_resources) | Runs Trivy with fewer resources | `bool` | `true` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | The namespace of the security services |
<!-- END_TF_DOCS -->
