<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0.0, < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_config_map_v1.jaeger_configuration](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_config_map_v1.ui_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_deployment_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_service_account_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |
| [kubernetes_service_v1.otlp_collector](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |
| [kubernetes_service_v1.tracing](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_jaeger_digest"></a> [jaeger\_digest](#input\_jaeger\_digest) | The digest of the Jaeger Service to be used | `string` | n/a | yes |
| <a name="input_jaeger_max_traces"></a> [jaeger\_max\_traces](#input\_jaeger\_max\_traces) | The maximum number of traces to be kept | `number` | `"50000"` | no |
| <a name="input_jaeger_storage_backend"></a> [jaeger\_storage\_backend](#input\_jaeger\_storage\_backend) | The storage backend for Jaeger | `string` | `"memory"` | no |
| <a name="input_jaeger_ttl_spans"></a> [jaeger\_ttl\_spans](#input\_jaeger\_ttl\_spans) | The time to live for spans stored in Jaeger | `string` | `"48h"` | no |
| <a name="input_jaeger_version"></a> [jaeger\_version](#input\_jaeger\_version) | The version of Jaeger to be installed | `string` | n/a | yes |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | Namespace where to install the services | `string` | `"istio-system"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_grpc_query_port"></a> [grpc\_query\_port](#output\_grpc\_query\_port) | The gRPC query port |
| <a name="output_http_query_port"></a> [http\_query\_port](#output\_http\_query\_port) | The HTTP query port |
| <a name="output_otlp_grpc_port"></a> [otlp\_grpc\_port](#output\_otlp\_grpc\_port) | The OpenTelemetry gRPC port |
| <a name="output_otlp_http_port"></a> [otlp\_http\_port](#output\_otlp\_http\_port) | The OpenTelemetry HTTP port |
| <a name="output_tracing_service_url"></a> [tracing\_service\_url](#output\_tracing\_service\_url) | The Jaeger gRPC Query URL |
<!-- END_TF_DOCS -->