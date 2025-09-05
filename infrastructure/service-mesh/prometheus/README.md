# prometheus

Module to deploy a Prometheus Instance to scrape metrics from running Workloads in the cluster. It activates by the default the scraping of metrics from the DEMIS applications over TLS.

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
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prometheus_helm_repository"></a> [prometheus\_helm\_repository](#input\_prometheus\_helm\_repository) | The Helm Repository to download the Prometheus Chart | `string` | `"https://prometheus-community.github.io/helm-charts"` | no |
| <a name="input_prometheus_version"></a> [prometheus\_version](#input\_prometheus\_version) | The version of Prometheus to be installed | `string` | n/a | yes |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | Namespace where to install the services | `string` | `"istio-system"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_prometheus_port"></a> [prometheus\_port](#output\_prometheus\_port) | The exposed Prometheus port |
| <a name="output_prometheus_service_url"></a> [prometheus\_service\_url](#output\_prometheus\_service\_url) | The Cluster-internal Prometheus URL |
<!-- END_TF_DOCS -->