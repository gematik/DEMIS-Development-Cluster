# kiali

This module deploys a Kiali Instance in a Kubernetes Cluster, by configuring it for Istio set in Sidecar mode.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0, < 4.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0.0, < 4.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.6.3, < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_secret_v1.kiali_service_account_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [random_string.kiali_signing_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_grafana_public_url"></a> [grafana\_public\_url](#input\_grafana\_public\_url) | Public URL of Grafana (the link in Kiali) | `string` | `null` | no |
| <a name="input_grafana_service_url"></a> [grafana\_service\_url](#input\_grafana\_service\_url) | Cluster-internal URL of Grafana, null switches the Grafana integration off | `string` | `null` | no |
| <a name="input_kiali_helm_repository"></a> [kiali\_helm\_repository](#input\_kiali\_helm\_repository) | The Helm Repository to download the Kiali Chart | `string` | `"https://kiali.org/helm-charts"` | no |
| <a name="input_kiali_version"></a> [kiali\_version](#input\_kiali\_version) | The version of Kiali to be installed | `string` | n/a | yes |
| <a name="input_prometheus_service_url"></a> [prometheus\_service\_url](#input\_prometheus\_service\_url) | Cluster-internal URL of Prometheus, null leaves it to the Kiali default | `string` | `null` | no |
| <a name="input_resource_definitions"></a> [resource\_definitions](#input\_resource\_definitions) | Per workload of the module (output of the resources module): replicas, resource block (YAML) and Istio proxy resources; null or missing keeps the defaults | <pre>map(object({<br/>    replicas       = optional(number)<br/>    resource_block = optional(string)<br/>    istio_proxy_resources = optional(object({<br/>      limits   = optional(map(string), {})<br/>      requests = optional(map(string), {})<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | Namespace where to install the services | `string` | `"observability"` | no |
| <a name="input_tracing_service_port"></a> [tracing\_service\_port](#input\_tracing\_service\_port) | gRPC query port of Jaeger | `string` | `"16685"` | no |
| <a name="input_tracing_service_url"></a> [tracing\_service\_url](#input\_tracing\_service\_url) | Cluster-internal gRPC query URL of Jaeger, null switches the tracing integration off | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_kiali_public_url"></a> [kiali\_public\_url](#output\_kiali\_public\_url) | Kiali Dashboard URL (requires port-forwarding) |
| <a name="output_kiali_service_url"></a> [kiali\_service\_url](#output\_kiali\_service\_url) | Cluster-internal Kiali Dashboard URL |
<!-- END_TF_DOCS -->
