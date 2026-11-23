<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0, < 4.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0.0, < 4.0.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.5.2, < 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_config_map_v1.grafana_base_dashboards](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_config_map_v1.grafana_demis_dashboards](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_config_map_v1.grafana_istio_dashboards](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_config_map_v1.grafana_istio_services_dashboards](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_config_map_v1.grafana_kubernetes_dashboards](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [terraform_data.dashboard_downloader](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_fetched_notifications_datasource"></a> [fetched\_notifications\_datasource](#input\_fetched\_notifications\_datasource) | PostgreSQL datasource on the fetched\_notifications database (Audit Log Service) via pgbouncer, read with the Grafana reader user; null disables it | <pre>object({<br/>    host                = string<br/>    port                = number<br/>    secret_name         = string<br/>    secret_key_user     = string<br/>    secret_key_password = string<br/>  })</pre> | `null` | no |
| <a name="input_grafana_digest"></a> [grafana\_digest](#input\_grafana\_digest) | The OCI digest of the Grafana Chart version | `string` | n/a | yes |
| <a name="input_grafana_helm_repository"></a> [grafana\_helm\_repository](#input\_grafana\_helm\_repository) | The OCI Helm Repository to download the Grafana Chart | `string` | `"oci://ghcr.io/grafana-community/helm-charts"` | no |
| <a name="input_grafana_version"></a> [grafana\_version](#input\_grafana\_version) | The version of the Grafana Chart to be installed | `string` | n/a | yes |
| <a name="input_istio_version"></a> [istio\_version](#input\_istio\_version) | The version of the Istio Services for downloading the correct dashboards | `string` | n/a | yes |
| <a name="input_loki_enabled"></a> [loki\_enabled](#input\_loki\_enabled) | Defines if a Loki datasource has to be added to Grafana | `bool` | `false` | no |
| <a name="input_loki_service_url"></a> [loki\_service\_url](#input\_loki\_service\_url) | Cluster-internal base URL of the Loki service, used for the Grafana Loki datasource (only relevant when loki\_enabled is true) | `string` | `"http://loki:3100"` | no |
| <a name="input_prometheus_enabled"></a> [prometheus\_enabled](#input\_prometheus\_enabled) | Defines if the Prometheus datasource and the dashboards (all based on Prometheus) have to be added to Grafana | `bool` | `false` | no |
| <a name="input_prometheus_service_url"></a> [prometheus\_service\_url](#input\_prometheus\_service\_url) | Cluster-internal URL of Prometheus, used for the Grafana Prometheus datasource (only relevant when prometheus\_enabled is true) | `string` | `""` | no |
| <a name="input_resource_definitions"></a> [resource\_definitions](#input\_resource\_definitions) | Per workload of the module (output of the resources module): replicas, resource block (YAML) and Istio proxy resources; null or missing keeps the defaults | <pre>map(object({<br/>    replicas       = optional(number)<br/>    resource_block = optional(string)<br/>    istio_proxy_resources = optional(object({<br/>      limits   = optional(map(string), {})<br/>      requests = optional(map(string), {})<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | Namespace where to install the services | `string` | `"observability"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_grafana_public_url"></a> [grafana\_public\_url](#output\_grafana\_public\_url) | Grafana Dashboard Public URL (Requires Port Forwarding) |
| <a name="output_grafana_service_url"></a> [grafana\_service\_url](#output\_grafana\_service\_url) | Grafana Dashboard URL |
<!-- END_TF_DOCS -->
