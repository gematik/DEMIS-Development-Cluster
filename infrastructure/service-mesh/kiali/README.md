# kiali

This module deploys a Kiali Instance in a Kubernetes Cluster, by configuring it for Istio set in Sidecar mode.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0, < 4.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.35.0, < 3.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.6.3, < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_secret_v1.kiali_service_account_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [random_string.kiali_signing_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_grafana_public_url"></a> [grafana\_public\_url](#input\_grafana\_public\_url) | The Public URL for Grafana (Used in Kiali as link, if activated) | `string` | `"http://localhost:3000"` | no |
| <a name="input_grafana_service_url"></a> [grafana\_service\_url](#input\_grafana\_service\_url) | The Cluster-internal URL of the Grafana Instance to be used | `string` | `"http://grafana:3000"` | no |
| <a name="input_kiali_helm_repository"></a> [kiali\_helm\_repository](#input\_kiali\_helm\_repository) | The Helm Repository to download the Kiali Chart | `string` | `"https://kiali.org/helm-charts"` | no |
| <a name="input_kiali_version"></a> [kiali\_version](#input\_kiali\_version) | The version of Kiali to be installed | `string` | n/a | yes |
| <a name="input_prometheus_service_url"></a> [prometheus\_service\_url](#input\_prometheus\_service\_url) | The Cluster-internal URL of the Prometheus Instance to be used | `string` | `"http://prometheus:9090"` | no |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | Namespace where to install the services | `string` | `"istio-system"` | no |
| <a name="input_tracing_service_url"></a> [tracing\_service\_url](#input\_tracing\_service\_url) | The Cluster-internal URL of the Tracing Instance to be used | `string` | `"http://tracing:16685/jaeger"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kiali_public_url"></a> [kiali\_public\_url](#output\_kiali\_public\_url) | Kiali Dashboard URL (requires port-forwarding) |
<!-- END_TF_DOCS -->