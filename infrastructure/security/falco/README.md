<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.1.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.falco](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | The Helm Chart Version for Falco | `string` | `"4.17.2"` | no |
| <a name="input_driver_kind"></a> [driver\_kind](#input\_driver\_kind) | sets the specfifc driver kind of the probe inside the nodes. Default of Falco is auto. The options are: kmod, ebpf, modern\_ebpf, We can enforce that if needed. | `string` | `"auto"` | no |
| <a name="input_falcosidekick_enabled"></a> [falcosidekick\_enabled](#input\_falcosidekick\_enabled) | enables falcosidekick | `bool` | `false` | no |
| <a name="input_falcosidekick_ui_enabled"></a> [falcosidekick\_ui\_enabled](#input\_falcosidekick\_ui\_enabled) | enables falcosidekick | `bool` | `false` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | The Helm Chart Repository for Falco | `string` | `"https://falcosecurity.github.io/charts"` | no |
| <a name="input_kubernetes_meta_collector"></a> [kubernetes\_meta\_collector](#input\_kubernetes\_meta\_collector) | enables the k8s metacollector plugin | `bool` | `true` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where to install Falco | `string` | `"security"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_chart_version"></a> [chart\_version](#output\_chart\_version) | Falco Helm Chart Version |
| <a name="output_helm_repository"></a> [helm\_repository](#output\_helm\_repository) | Falco Helm Repository |
<!-- END_TF_DOCS -->