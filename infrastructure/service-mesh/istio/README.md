# istio

This module deploys the Helm Charts for running Istio in Sidecar mode.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.17.0, < 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.istio_base](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.istio_cni](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.istio_egressgateway](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.istio_ingressgateway](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.istiod](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | The version of the Istio Helm Chart to be installed | `string` | n/a | yes |
| <a name="input_external_ip"></a> [external\_ip](#input\_external\_ip) | The external IP of the ingress gateway, only single IP is supported | `string` | `""` | no |
| <a name="input_helm_repository"></a> [helm\_repository](#input\_helm\_repository) | Helm Chart Repository URL | `string` | `"https://istio-release.storage.googleapis.com/charts"` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | The annotations to be used for the ingress gateway | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_local_deployment"></a> [local\_deployment](#input\_local\_deployment) | Defines if the components (Grafana, Prometheus) have to be installed locally. | `bool` | `false` | no |
| <a name="input_local_node_ports_istio"></a> [local\_node\_ports\_istio](#input\_local\_node\_ports\_istio) | Defines the node ports to use with the local cluster (kind) | <pre>list(object({<br/>    port       = number<br/>    targetPort = number<br/>    name       = string<br/>    protocol   = string<br/>    nodePort   = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "name": "status-port",<br/>    "nodePort": 30002,<br/>    "port": 15021,<br/>    "protocol": "TCP",<br/>    "targetPort": 15021<br/>  },<br/>  {<br/>    "name": "http2",<br/>    "nodePort": 30000,<br/>    "port": 80,<br/>    "protocol": "TCP",<br/>    "targetPort": 80<br/>  },<br/>  {<br/>    "name": "https",<br/>    "nodePort": 30001,<br/>    "port": 443,<br/>    "protocol": "TCP",<br/>    "targetPort": 443<br/>  }<br/>]</pre> | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where to install the services | `string` | `"istio-system"` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | The number of replicas that have to be configured for the services | `number` | `3` | no |
| <a name="input_trace_sampling"></a> [trace\_sampling](#input\_trace\_sampling) | The sampling rate option can be used to control what percentage of requests get reported to your tracing system. (https://istio.io/latest/docs/tasks/observability/distributed-tracing/mesh-and-proxy-config/#customizing-trace-sampling) | `string` | `"1.0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_istio_health_port"></a> [istio\_health\_port](#output\_istio\_health\_port) | The Istio Health port |
| <a name="output_istio_http_port"></a> [istio\_http\_port](#output\_istio\_http\_port) | The Istio HTTP port |
| <a name="output_istio_https_port"></a> [istio\_https\_port](#output\_istio\_https\_port) | The Istio HTTPS port |
<!-- END_TF_DOCS -->