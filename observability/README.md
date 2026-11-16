# observability

Layer to deploy the observability tools (Prometheus, Grafana, Loki, Jaeger, Kiali) and the Audit Log Service, deployed after the infrastructure and before the mesh (`make <stage> observability`). Without the project feature flag `FEATURE_FLAG_OBSERVABILITY_NAMESPACE_ENABLED`, Kiali and Jaeger stay in `istio-system`; Grafana and Loki run with an Envoy sidecar inside the Service Mesh.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 3.3.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_audit_log_service"></a> [audit\_log\_service](#module\_audit\_log\_service) | ./audit-log-service | n/a |
| <a name="module_grafana"></a> [grafana](#module\_grafana) | ./grafana | n/a |
| <a name="module_jaeger"></a> [jaeger](#module\_jaeger) | ./jaeger | n/a |
| <a name="module_kiali"></a> [kiali](#module\_kiali) | ./kiali | n/a |
| <a name="module_loki"></a> [loki](#module\_loki) | ./loki | n/a |
| <a name="module_metadata"></a> [metadata](#module\_metadata) | ../modules/metadata | n/a |
| <a name="module_namespace"></a> [namespace](#module\_namespace) | ../modules/namespace | n/a |
| <a name="module_prometheus"></a> [prometheus](#module\_prometheus) | ./prometheus | n/a |
| <a name="module_pull_secrets"></a> [pull\_secrets](#module\_pull\_secrets) | ../modules/pull_secret | n/a |

## Resources

| Name | Type |
| ---- | ---- |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_audit_log_service_audited_namespace"></a> [audit\_log\_service\_audited\_namespace](#input\_audit\_log\_service\_audited\_namespace) | Namespace of the audited workloads (fhir-storage-reader/-writer) | `string` | `"demis"` | no |
| <a name="input_audit_log_service_docker_registry"></a> [audit\_log\_service\_docker\_registry](#input\_audit\_log\_service\_docker\_registry) | Docker registry of the Audit Log Service image | `string` | `"europe-west3-docker.pkg.dev/gematik-all-infra-prod/demis-dev"` | no |
| <a name="input_audit_log_service_replica_count"></a> [audit\_log\_service\_replica\_count](#input\_audit\_log\_service\_replica\_count) | Number of Audit Log Service replicas | `number` | `1` | no |
| <a name="input_demis_helm_repository"></a> [demis\_helm\_repository](#input\_demis\_helm\_repository) | Helm Repository URL of the DEMIS charts (Audit Log Service, istio-routing), used if helm\_repository\_source is 'url' | `string` | `null` | no |
| <a name="input_docker_pull_secrets"></a> [docker\_pull\_secrets](#input\_docker\_pull\_secrets) | Pull Secrets for the Audit Log Service image (see docker\_pull\_secrets of the infrastructure) | <pre>list(object({<br/>    name          = string<br/>    registry      = string<br/>    user_name     = string<br/>    user_email    = string<br/>    user_password = string<br/>    password_type = string<br/>  }))</pre> | `[]` | no |
| <a name="input_fallback_namespace"></a> [fallback\_namespace](#input\_fallback\_namespace) | Namespace used if the namespace is not needed (no monitoring, no Audit Log Service, Kiali and Jaeger not moved), and for Kiali and Jaeger unless kiali\_jaeger\_in\_namespace | `string` | `"istio-system"` | no |
| <a name="input_google_cloud_access_token"></a> [google\_cloud\_access\_token](#input\_google\_cloud\_access\_token) | Access Token used for the Pull Secrets with password\_type 'token' | `string` | `""` | no |
| <a name="input_grafana_public_url"></a> [grafana\_public\_url](#input\_grafana\_public\_url) | The Public URL for Grafana (Used in Kiali as link, if activated) | `string` | `"http://localhost:3000"` | no |
| <a name="input_grafana_service_url"></a> [grafana\_service\_url](#input\_grafana\_service\_url) | The Cluster-internal URL of the Grafana Instance to be used | `string` | `"http://grafana:3000"` | no |
| <a name="input_helm_repository_names"></a> [helm\_repository\_names](#input\_helm\_repository\_names) | Repository names in the Helm repositories.yaml per chart, used if helm\_repository\_source is 'local' | <pre>object({<br/>    kiali      = optional(string, "kiali")<br/>    prometheus = optional(string, "prometheus-community")<br/>    loki       = optional(string, "grafana-community")<br/>    demis      = optional(string, "demis")<br/>  })</pre> | `{}` | no |
| <a name="input_helm_repository_password"></a> [helm\_repository\_password](#input\_helm\_repository\_password) | The Password credential for the DEMIS Helm Repository, used if helm\_repository\_source is 'url' | `string` | `""` | no |
| <a name="input_helm_repository_source"></a> [helm\_repository\_source](#input\_helm\_repository\_source) | Where Helm Charts are resolved from: 'url' uses the public repository URLs and demis\_helm\_repository, 'local' uses the repository names from helm\_repository\_names in the Helm repositories.yaml | `string` | `"url"` | no |
| <a name="input_helm_repository_username"></a> [helm\_repository\_username](#input\_helm\_repository\_username) | The Username credential for the DEMIS Helm Repository, used if helm\_repository\_source is 'url' | `string` | `""` | no |
| <a name="input_jaeger_max_traces"></a> [jaeger\_max\_traces](#input\_jaeger\_max\_traces) | The maximum number of traces to be kept | `number` | `null` | no |
| <a name="input_jaeger_storage_backend"></a> [jaeger\_storage\_backend](#input\_jaeger\_storage\_backend) | The storage backend for Jaeger | `string` | `null` | no |
| <a name="input_jaeger_ttl_spans"></a> [jaeger\_ttl\_spans](#input\_jaeger\_ttl\_spans) | The time to live for spans stored in Jaeger | `string` | `null` | no |
| <a name="input_kms_encryption_key"></a> [kms\_encryption\_key](#input\_kms\_encryption\_key) | The GCP KMS encryption key for OpenTofu state encryption | `string` | `""` | no |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to the kubeconfig file of the cluster | `string` | `"~/.kube/config"` | no |
| <a name="input_loki_backend_replicas"></a> [loki\_backend\_replicas](#input\_loki\_backend\_replicas) | Replica count for the SimpleScalable backend target. Defaults to loki\_replicas when not set. | `number` | `null` | no |
| <a name="input_loki_deployment_mode"></a> [loki\_deployment\_mode](#input\_loki\_deployment\_mode) | Loki deployment topology. Options: Monolithic (default) or SimpleScalable (requires s3 storage). | `string` | `"Monolithic"` | no |
| <a name="input_loki_read_replicas"></a> [loki\_read\_replicas](#input\_loki\_read\_replicas) | Replica count for the SimpleScalable read target. Defaults to loki\_replicas when not set. | `number` | `null` | no |
| <a name="input_loki_replicas"></a> [loki\_replicas](#input\_loki\_replicas) | Number of Loki instances. Must be 1 for filesystem storage; values > 1 require S3 storage. In SimpleScalable mode this is the default for the read/write/backend targets unless overridden. | `number` | `1` | no |
| <a name="input_loki_retention_period"></a> [loki\_retention\_period](#input\_loki\_retention\_period) | How long ingested logs are kept before deletion (Go duration, e.g. 168h). | `string` | `"168h"` | no |
| <a name="input_loki_s3_access_key_id"></a> [loki\_s3\_access\_key\_id](#input\_loki\_s3\_access\_key\_id) | The S3 access key id used when loki\_storage\_type is s3. | `string` | `""` | no |
| <a name="input_loki_s3_bucket_admin"></a> [loki\_s3\_bucket\_admin](#input\_loki\_s3\_bucket\_admin) | S3 bucket for Loki admin/compactor objects. | `string` | `""` | no |
| <a name="input_loki_s3_bucket_chunks"></a> [loki\_s3\_bucket\_chunks](#input\_loki\_s3\_bucket\_chunks) | S3 bucket for Loki chunks. | `string` | `""` | no |
| <a name="input_loki_s3_bucket_ruler"></a> [loki\_s3\_bucket\_ruler](#input\_loki\_s3\_bucket\_ruler) | S3 bucket for Loki ruler rules. | `string` | `""` | no |
| <a name="input_loki_s3_endpoint"></a> [loki\_s3\_endpoint](#input\_loki\_s3\_endpoint) | S3 endpoint host used when loki\_storage\_type is s3. | `string` | `""` | no |
| <a name="input_loki_s3_force_path_style"></a> [loki\_s3\_force\_path\_style](#input\_loki\_s3\_force\_path\_style) | Use path-style S3 URLs (true for MinIO / non-AWS, false for real AWS S3). | `bool` | `true` | no |
| <a name="input_loki_s3_insecure"></a> [loki\_s3\_insecure](#input\_loki\_s3\_insecure) | Talk to the S3 endpoint over plain HTTP instead of HTTPS. | `bool` | `false` | no |
| <a name="input_loki_s3_region"></a> [loki\_s3\_region](#input\_loki\_s3\_region) | S3 region used when loki\_storage\_type is s3 (may be empty for MinIO / non-AWS). | `string` | `""` | no |
| <a name="input_loki_s3_secret_access_key"></a> [loki\_s3\_secret\_access\_key](#input\_loki\_s3\_secret\_access\_key) | The S3 secret access key used when loki\_storage\_type is s3. | `string` | `""` | no |
| <a name="input_loki_storage_type"></a> [loki\_storage\_type](#input\_loki\_storage\_type) | Storage backend for Loki. Options: filesystem (default) or s3 (external object storage). | `string` | `"filesystem"` | no |
| <a name="input_loki_write_replicas"></a> [loki\_write\_replicas](#input\_loki\_write\_replicas) | Replica count for the SimpleScalable write target. Defaults to loki\_replicas when not set. | `number` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace that is created for the observability services (Prometheus, Grafana, Loki; Kiali and Jaeger if kiali\_jaeger\_in\_namespace) | `string` | `"observability"` | no |
| <a name="input_override_stage_name"></a> [override\_stage\_name](#input\_override\_stage\_name) | Override the stage name detected from the cluster labels (local or <cluster>-<region>), used for the stage folder of the active-versions.yaml | `string` | `""` | no |
| <a name="input_project_feature_flags"></a> [project\_feature\_flags](#input\_project\_feature\_flags) | Project feature flags: FEATURE\_FLAG\_OBSERVABILITY\_NAMESPACE\_ENABLED switches from the legacy observability in the infrastructure to this module (same value as in the infrastructure), FEATURE\_FLAG\_AUDIT\_LOG\_FSSR\_ENABLED / FEATURE\_FLAG\_AUDIT\_LOG\_FSSW\_ENABLED switch the Audit Log Service | `map(bool)` | `{}` | no |
| <a name="input_prometheus_service_url"></a> [prometheus\_service\_url](#input\_prometheus\_service\_url) | The Cluster-internal URL of the Prometheus Instance to be used | `string` | `"http://prometheus:9090"` | no |
| <a name="input_tracing_service_url"></a> [tracing\_service\_url](#input\_tracing\_service\_url) | The Cluster-internal URL of the Tracing Instance to be used | `string` | `"http://tracing:16685/jaeger"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_kiali_jaeger_namespace"></a> [kiali\_jaeger\_namespace](#output\_kiali\_jaeger\_namespace) | Namespace of Kiali and Jaeger |
| <a name="output_kms_encryption_key_used"></a> [kms\_encryption\_key\_used](#output\_kms\_encryption\_key\_used) | The flag to indicate if the KMS encryption key is used |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace of Prometheus, Grafana, Loki and the Audit Log Service |
| <a name="output_url_grafana"></a> [url\_grafana](#output\_url\_grafana) | Grafana Dashboard URL |
| <a name="output_url_jaeger"></a> [url\_jaeger](#output\_url\_jaeger) | Jaeger URL |
| <a name="output_url_kiali"></a> [url\_kiali](#output\_url\_kiali) | Kiali Dashboard URL |
<!-- END_TF_DOCS -->
