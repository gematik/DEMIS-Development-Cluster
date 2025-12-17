# service-mesh

Module to deploy a complete Service Mesh based on Istio with Sidecar and observability tools

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_grafana"></a> [grafana](#module\_grafana) | ./grafana | n/a |
| <a name="module_istio"></a> [istio](#module\_istio) | ./istio | n/a |
| <a name="module_jaeger"></a> [jaeger](#module\_jaeger) | ./jaeger | n/a |
| <a name="module_kiali"></a> [kiali](#module\_kiali) | ./kiali | n/a |
| <a name="module_prometheus"></a> [prometheus](#module\_prometheus) | ./prometheus | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_native_sidecar_injection"></a> [enable\_native\_sidecar\_injection](#input\_enable\_native\_sidecar\_injection) | Enable native sidecar injection for Istio (supported in Kubernetes 1.33.0+ and Istio 1.27.0+) | `bool` | `null` | no |
| <a name="input_external_ip"></a> [external\_ip](#input\_external\_ip) | The external IP of the ingress gateway, only single IP is supported | `string` | `""` | no |
| <a name="input_grafana_digest"></a> [grafana\_digest](#input\_grafana\_digest) | The digest of the Grafana Service to be used | `string` | `"sha256:5781759b3d27734d4d548fcbaf60b1180dbf4290e708f01f292faa6ae764c5e6"` | no |
| <a name="input_grafana_enabled"></a> [grafana\_enabled](#input\_grafana\_enabled) | Defines if Grafana has to be deployed | `bool` | `false` | no |
| <a name="input_grafana_public_url"></a> [grafana\_public\_url](#input\_grafana\_public\_url) | The Public URL for Grafana (Used in Kiali as link, if activated) | `string` | `"http://localhost:3000"` | no |
| <a name="input_grafana_service_url"></a> [grafana\_service\_url](#input\_grafana\_service\_url) | The Cluster-internal URL of the Grafana Instance to be used | `string` | `"http://grafana:3000"` | no |
| <a name="input_grafana_version"></a> [grafana\_version](#input\_grafana\_version) | The version of the Grafana Service to be installed | `string` | `"11.5.1"` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | The annotations to be used for the ingress gateway | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_istio_replica_count"></a> [istio\_replica\_count](#input\_istio\_replica\_count) | The number of replicas that have to be configured for the Istio services | `number` | `3` | no |
| <a name="input_istio_version"></a> [istio\_version](#input\_istio\_version) | The version of the Istio Helm Chart to be installed. | `string` | `"1.23.0"` | no |
| <a name="input_jaeger_digest"></a> [jaeger\_digest](#input\_jaeger\_digest) | The digest of the Jaeger Service to be used | `string` | `"sha256:9864182b4e01350fcc64631bdba5f4085f87daae9d477a04c25d9cb362e787a9"` | no |
| <a name="input_jaeger_enabled"></a> [jaeger\_enabled](#input\_jaeger\_enabled) | Defines if Jaeger has to be deployed | `bool` | `true` | no |
| <a name="input_jaeger_max_traces"></a> [jaeger\_max\_traces](#input\_jaeger\_max\_traces) | The maximum number of traces to be kept | `number` | `null` | no |
| <a name="input_jaeger_storage_backend"></a> [jaeger\_storage\_backend](#input\_jaeger\_storage\_backend) | The storage backend for Jaeger | `string` | `null` | no |
| <a name="input_jaeger_ttl_spans"></a> [jaeger\_ttl\_spans](#input\_jaeger\_ttl\_spans) | The time to live for spans stored in Jaeger | `string` | `null` | no |
| <a name="input_jaeger_version"></a> [jaeger\_version](#input\_jaeger\_version) | The version of the Jaeger Service to be installed | `string` | `"1.66.0"` | no |
| <a name="input_kiali_enabled"></a> [kiali\_enabled](#input\_kiali\_enabled) | Defines if Kiali has to be deployed | `bool` | `true` | no |
| <a name="input_kiali_version"></a> [kiali\_version](#input\_kiali\_version) | The version of the Kiali Helm Chart to be installed | `string` | `"2.5.0"` | no |
| <a name="input_local_deployment"></a> [local\_deployment](#input\_local\_deployment) | Defines if the components (Grafana, Prometheus) have to be installed locally. | `bool` | `false` | no |
| <a name="input_local_node_ports_istio"></a> [local\_node\_ports\_istio](#input\_local\_node\_ports\_istio) | Defines the node ports to use with the local cluster (kind) | <pre>list(object({<br/>    port       = number<br/>    targetPort = number<br/>    name       = string<br/>    protocol   = string<br/>    nodePort   = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "name": "status-port",<br/>    "nodePort": 30002,<br/>    "port": 15021,<br/>    "protocol": "TCP",<br/>    "targetPort": 15021<br/>  },<br/>  {<br/>    "name": "http2",<br/>    "nodePort": 30000,<br/>    "port": 80,<br/>    "protocol": "TCP",<br/>    "targetPort": 80<br/>  },<br/>  {<br/>    "name": "https",<br/>    "nodePort": 30001,<br/>    "port": 443,<br/>    "protocol": "TCP",<br/>    "targetPort": 443<br/>  }<br/>]</pre> | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where to install the services | `string` | `"istio-system"` | no |
| <a name="input_prometheus_enabled"></a> [prometheus\_enabled](#input\_prometheus\_enabled) | Defines if Prometheus has to be deployed | `bool` | `false` | no |
| <a name="input_prometheus_service_url"></a> [prometheus\_service\_url](#input\_prometheus\_service\_url) | The Cluster-internal URL of the Prometheus Instance to be used | `string` | `"http://prometheus:9090"` | no |
| <a name="input_prometheus_version"></a> [prometheus\_version](#input\_prometheus\_version) | The version of the Prometheus Service to be installed | `string` | `"27.3.0"` | no |
| <a name="input_trace_sampling"></a> [trace\_sampling](#input\_trace\_sampling) | The sampling rate option can be used to control what percentage of requests get reported to your tracing system. (https://istio.io/latest/docs/tasks/observability/distributed-tracing/mesh-and-proxy-config/#customizing-trace-sampling) | `string` | `"1.0"` | no |
| <a name="input_tracing_service_url"></a> [tracing\_service\_url](#input\_tracing\_service\_url) | The Cluster-internal URL of the Tracing Instance to be used | `string` | `"http://tracing:16685/jaeger"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_istio_health_port"></a> [istio\_health\_port](#output\_istio\_health\_port) | The Istio Health port |
| <a name="output_istio_http_port"></a> [istio\_http\_port](#output\_istio\_http\_port) | The Istio HTTP port |
| <a name="output_istio_https_port"></a> [istio\_https\_port](#output\_istio\_https\_port) | The Istio HTTPS port |
| <a name="output_url_grafana"></a> [url\_grafana](#output\_url\_grafana) | Grafana Dashboard URL |
| <a name="output_url_jaeger"></a> [url\_jaeger](#output\_url\_jaeger) | Jaeger URL |
| <a name="output_url_kiali"></a> [url\_kiali](#output\_url\_kiali) | Kiali Dashboard URL |
<!-- END_TF_DOCS -->