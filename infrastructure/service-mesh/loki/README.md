# loki

Module to deploy a Loki instance as central log receiver in monolithic (single-binary) mode. The chart is pulled from the grafana-community OCI registry (`oci://ghcr.io/grafana-community/helm-charts/loki`). The DEMIS applications actively push their logs to the Loki Push-API (`http://loki:3100/loki/api/v1/push`); no log collector (Promtail/Alloy) is deployed. Loki is only rolled out together with Grafana (see the `service_mesh_loki_enabled` flag in the `infrastructure` root module).

The storage backend is configurable via `loki_storage`: `filesystem` (local disk, default) for local/non-HA setups, or `s3` for an external S3-compatible object store (required for running more than one replica). S3 credentials are injected as sensitive Helm values via `loki_s3_access_key_id` / `loki_s3_secret_access_key` and are never written into the chart values file; leaving them empty falls back to an IAM role / instance profile.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0, < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_loki_backend_replicas"></a> [loki\_backend\_replicas](#input\_loki\_backend\_replicas) | Replica count for the SimpleScalable backend target (compactor / ruler / index-gateway). Defaults to loki\_replicas when not set. Ignored in Monolithic mode. | `number` | `null` | no |
| <a name="input_loki_deployment_mode"></a> [loki\_deployment\_mode](#input\_loki\_deployment\_mode) | Loki chart deployment topology. Options: "Monolithic" (all components in one single-binary process; works with filesystem storage) or "SimpleScalable" (separate read/write/backend targets behind a gateway; requires S3 storage). | `string` | `"Monolithic"` | no |
| <a name="input_loki_helm_repository"></a> [loki\_helm\_repository](#input\_loki\_helm\_repository) | The Helm Repository to download the Loki Chart | `string` | `"oci://ghcr.io/grafana-community/helm-charts"` | no |
| <a name="input_loki_read_replicas"></a> [loki\_read\_replicas](#input\_loki\_read\_replicas) | Replica count for the SimpleScalable read target (queriers / query-frontend). Defaults to loki\_replicas when not set. Ignored in Monolithic mode. | `number` | `null` | no |
| <a name="input_loki_replicas"></a> [loki\_replicas](#input\_loki\_replicas) | Number of Loki instances for the monolithic target. Must be 1 for filesystem storage; values > 1 require S3 storage. In SimpleScalable mode this is the default replica count for the read/write/backend targets unless overridden. | `number` | `1` | no |
| <a name="input_loki_retention_period"></a> [loki\_retention\_period](#input\_loki\_retention\_period) | How long ingested logs are kept before the compactor deletes them (Go duration, e.g. 24h, 168h, 720h). | `string` | `"168h"` | no |
| <a name="input_loki_s3_access_key_id"></a> [loki\_s3\_access\_key\_id](#input\_loki\_s3\_access\_key\_id) | The S3 access key id used when loki\_storage\_type is "s3". Leave empty to rely on an IAM role / instance profile. | `string` | `""` | no |
| <a name="input_loki_s3_bucket_admin"></a> [loki\_s3\_bucket\_admin](#input\_loki\_s3\_bucket\_admin) | S3 bucket for Loki admin/compactor objects (used when loki\_storage\_type is "s3"). | `string` | `""` | no |
| <a name="input_loki_s3_bucket_chunks"></a> [loki\_s3\_bucket\_chunks](#input\_loki\_s3\_bucket\_chunks) | S3 bucket for Loki chunks (used when loki\_storage\_type is "s3"). | `string` | `""` | no |
| <a name="input_loki_s3_bucket_ruler"></a> [loki\_s3\_bucket\_ruler](#input\_loki\_s3\_bucket\_ruler) | S3 bucket for Loki ruler rules (used when loki\_storage\_type is "s3"). | `string` | `""` | no |
| <a name="input_loki_s3_endpoint"></a> [loki\_s3\_endpoint](#input\_loki\_s3\_endpoint) | S3 endpoint host used when loki\_storage\_type is "s3" (e.g. "s3.eu-central-1.amazonaws.com" or a MinIO host). | `string` | `""` | no |
| <a name="input_loki_s3_force_path_style"></a> [loki\_s3\_force\_path\_style](#input\_loki\_s3\_force\_path\_style) | Use path-style S3 URLs. true for MinIO / most non-AWS endpoints, false for real AWS S3. | `bool` | `true` | no |
| <a name="input_loki_s3_insecure"></a> [loki\_s3\_insecure](#input\_loki\_s3\_insecure) | Talk to the S3 endpoint over plain HTTP instead of HTTPS. | `bool` | `false` | no |
| <a name="input_loki_s3_region"></a> [loki\_s3\_region](#input\_loki\_s3\_region) | S3 region used when loki\_storage\_type is "s3" (may be empty for MinIO / non-AWS endpoints). | `string` | `""` | no |
| <a name="input_loki_s3_secret_access_key"></a> [loki\_s3\_secret\_access\_key](#input\_loki\_s3\_secret\_access\_key) | The S3 secret access key used when loki\_storage\_type is "s3". Leave empty to rely on an IAM role / instance profile. | `string` | `""` | no |
| <a name="input_loki_storage_type"></a> [loki\_storage\_type](#input\_loki\_storage\_type) | Storage backend for Loki chunks/indexes. Options: "filesystem" (local disk, default) or "s3" (external S3-compatible object storage, required for more than one replica). | `string` | `"filesystem"` | no |
| <a name="input_loki_version"></a> [loki\_version](#input\_loki\_version) | The version of Loki to be installed | `string` | n/a | yes |
| <a name="input_loki_write_replicas"></a> [loki\_write\_replicas](#input\_loki\_write\_replicas) | Replica count for the SimpleScalable write target (distributors / ingesters). Defaults to loki\_replicas when not set. Ignored in Monolithic mode. | `number` | `null` | no |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | Namespace where to install the services | `string` | `"istio-system"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_loki_otlp_logs_url"></a> [loki\_otlp\_logs\_url](#output\_loki\_otlp\_logs\_url) | The Loki native OTLP logs endpoint (OTLP over HTTP). Applications can push logs<br/>directly via OTLP/HTTP without a collector. Note: Loki only accepts OTLP over HTTP,<br/>there is no OTLP/gRPC log receiver - the gRPC port 9095 is for internal component<br/>traffic only. |
| <a name="output_loki_port"></a> [loki\_port](#output\_loki\_port) | The client-facing Loki port (3100 for Monolithic, 80 for the SimpleScalable gateway) |
| <a name="output_loki_push_url"></a> [loki\_push\_url](#output\_loki\_push\_url) | The Loki native Push-API endpoint (Loki line protocol, HTTP) |
| <a name="output_loki_service_url"></a> [loki\_service\_url](#output\_loki\_service\_url) | The Cluster-internal Loki base URL (host:port for Push-API, OTLP and query endpoints) |
<!-- END_TF_DOCS -->
