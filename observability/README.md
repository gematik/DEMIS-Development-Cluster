# observability

Layer to deploy the observability tools (Prometheus, Grafana, Loki, Jaeger, Kiali) and the Audit Log Service, deployed after the infrastructure and the mesh (`make <stage> observability`). Without the project feature flag `FEATURE_FLAG_OBSERVABILITY_NAMESPACE_ENABLED`, Kiali and Jaeger stay in `istio-system`.

Like the other layers, the namespace has its own stateful services (switched in the `active-versions.yaml`):

- `object-storage-service`: S3 storage of Loki (own bucket with object lock and optional SSE-S3, only Loki may access it). Stages with an externally managed SeaweedFS disable it. The endpoint is always set with `loki_s3_endpoint` in the `application-configuration.tfvars`, as `s3_hostname` in the demis module.
- `postgres` and `pgbouncer`: database `fetched_notifications` of the Audit Log Service; Grafana reads it with the Grafana reader user (datasource `fetched-notifications`)
- `audit-log-purger`: CronJob purging the `fetched_notifications` (`audit_log_purger_cron_schedule`, `audit_log_purger_suspend`); after a new version it runs once immediately, as the purgers of the demis layer

All workloads of the namespace run with an Envoy sidecar under STRICT mTLS (`network-rules` in the `active-versions.yaml`); only the node-exporter runs without. Their sidecars report no spans except the Audit Log Service, pgbouncer and Postgres (Telemetry of the own `network-rules`), and Jaeger drops the traces of calls to the observability tools (e.g. the OTLP export through the Ingress Gateway). Prometheus scrapes in plain HTTP, so the metrics ports of kube-state-metrics and Kiali bypass the sidecar.

The Istio authorization policies of the namespace come from the policies chart (`policies-authorizations` in the `active-versions.yaml`, values in `policies-authorizations/istio-values.tftpl.yaml` of the stage): only the Audit Log Service pushes logs to and only Grafana queries Loki (no gateway, no password), only Loki reaches the object-storage-service, only Grafana, the Audit Log Service and the Audit Log Purger reach pgbouncer.

On the stages with network policies (DEV, PROD; not local and public), the `kubernetes-network-policies` chart (`kubernetes-network-policies` in the `active-versions.yaml`) additionally denies all ingress except for the Audit Log Service, Loki (Audit Log Service, Grafana, Loki itself), postgres and pgbouncer. As in the other layers, the stage file `kubernetes-network-policies/values.tftpl.yaml` selects the policies of this layer (`observability.enabled: true`, `demis.enabled: false`).

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
| <a name="module_activate_maintenance_mode"></a> [activate\_maintenance\_mode](#module\_activate\_maintenance\_mode) | ../modules/maintenance_mode | n/a |
| <a name="module_application_flags"></a> [application\_flags](#module\_application\_flags) | ../modules/flags | n/a |
| <a name="module_application_resources"></a> [application\_resources](#module\_application\_resources) | ../modules/resources | n/a |
| <a name="module_deactivate_maintenance_mode"></a> [deactivate\_maintenance\_mode](#module\_deactivate\_maintenance\_mode) | ../modules/maintenance_mode | n/a |
| <a name="module_metadata"></a> [metadata](#module\_metadata) | ../modules/metadata | n/a |
| <a name="module_namespace"></a> [namespace](#module\_namespace) | ../modules/namespace | n/a |
| <a name="module_observability_services"></a> [observability\_services](#module\_observability\_services) | ./applications | n/a |
| <a name="module_persistent_volume_claims"></a> [persistent\_volume\_claims](#module\_persistent\_volume\_claims) | ../modules/persistence_volume_claim | n/a |
| <a name="module_pull_secrets"></a> [pull\_secrets](#module\_pull\_secrets) | ../modules/pull_secret | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.authorization_policies_istio](https://registry.terraform.io/providers/hashicorp/helm/3.3.0/docs/resources/release) | resource |
| [helm_release.kubernetes_network_policies](https://registry.terraform.io/providers/hashicorp/helm/3.3.0/docs/resources/release) | resource |
| [helm_release.network_rules_istio](https://registry.terraform.io/providers/hashicorp/helm/3.3.0/docs/resources/release) | resource |
| [terraform_data.audit_log_purger_manual_trigger](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_audit_log_purger_cron_schedule"></a> [audit\_log\_purger\_cron\_schedule](#input\_audit\_log\_purger\_cron\_schedule) | Cron schedule of the audit-log-purger | `string` | `"0 22 * * *"` | no |
| <a name="input_audit_log_purger_suspend"></a> [audit\_log\_purger\_suspend](#input\_audit\_log\_purger\_suspend) | Defines if the CronJob of the audit-log-purger is suspended | `bool` | `false` | no |
| <a name="input_audit_log_service_audited_namespaces"></a> [audit\_log\_service\_audited\_namespaces](#input\_audit\_log\_service\_audited\_namespaces) | Namespaces audited by the Audit Log Service per layer (one observability namespace audits several namespaces); the filters per layer are defined in the chart values template | <pre>object({<br/>    demis = optional(list(string), ["demis"])<br/>    dmz   = optional(list(string), [])<br/>    are   = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_config_options"></a> [config\_options](#input\_config\_options) | Defines a list of configuration options that belong to services | <pre>list(object({<br/>    services     = list(string)<br/>    option_name  = string<br/>    option_value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_database_credentials"></a> [database\_credentials](#input\_database\_credentials) | Database credentials of postgres (admin and the fetched\_notifications users), as database\_credentials of the demis module | <pre>list(object({<br/>    username            = string<br/>    password            = string<br/>    secret-name         = string<br/>    secret-key-user     = string<br/>    secret-key-password = string<br/>  }))</pre> | `[]` | no |
| <a name="input_debug_enabled"></a> [debug\_enabled](#input\_debug\_enabled) | Defines if the backend Java Services must be started in Debug Mode | `bool` | `false` | no |
| <a name="input_demis_helm_repository"></a> [demis\_helm\_repository](#input\_demis\_helm\_repository) | Helm Repository URL of the DEMIS charts (Audit Log Service, istio-routing), used if helm\_repository\_source is 'url' | `string` | `null` | no |
| <a name="input_docker_pull_secrets"></a> [docker\_pull\_secrets](#input\_docker\_pull\_secrets) | Pull Secrets for the Audit Log Service image (see docker\_pull\_secrets of the infrastructure) | <pre>list(object({<br/>    name          = string<br/>    registry      = string<br/>    user_name     = string<br/>    user_email    = string<br/>    user_password = string<br/>    password_type = string<br/>  }))</pre> | `[]` | no |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | Docker registry of the DEMIS images (Audit Log Service, object-storage-service, postgres, pgbouncer) | `string` | `"europe-west3-docker.pkg.dev/gematik-all-infra-prod/demis-dev"` | no |
| <a name="input_feature_flags"></a> [feature\_flags](#input\_feature\_flags) | Defines a list of feature flags that belong to services | <pre>list(object({<br/>    services   = list(string)<br/>    flag_name  = string<br/>    flag_value = bool<br/>  }))</pre> | `[]` | no |
| <a name="input_google_cloud_access_token"></a> [google\_cloud\_access\_token](#input\_google\_cloud\_access\_token) | Access Token used for the Pull Secrets with password\_type 'token' | `string` | `""` | no |
| <a name="input_grafana_public_url"></a> [grafana\_public\_url](#input\_grafana\_public\_url) | Public URL of Grafana, the link in Kiali; null for the one of the Grafana of this namespace (if deployed) | `string` | `null` | no |
| <a name="input_grafana_service_url"></a> [grafana\_service\_url](#input\_grafana\_service\_url) | Cluster-internal URL of Grafana for Kiali, null for the Grafana of this namespace (if deployed) | `string` | `null` | no |
| <a name="input_helm_repository_names"></a> [helm\_repository\_names](#input\_helm\_repository\_names) | Repository names in the Helm repositories.yaml per chart, used if helm\_repository\_source is 'local' | <pre>object({<br/>    kiali      = optional(string, "kiali")<br/>    prometheus = optional(string, "prometheus-community")<br/>    loki       = optional(string, "grafana-community")<br/>    demis      = optional(string, "demis")<br/>  })</pre> | `{}` | no |
| <a name="input_helm_repository_password"></a> [helm\_repository\_password](#input\_helm\_repository\_password) | The Password credential for the DEMIS Helm Repository, used if helm\_repository\_source is 'url' | `string` | `""` | no |
| <a name="input_helm_repository_source"></a> [helm\_repository\_source](#input\_helm\_repository\_source) | Where Helm Charts are resolved from: 'url' uses the public repository URLs and demis\_helm\_repository, 'local' uses the repository names from helm\_repository\_names in the Helm repositories.yaml | `string` | `"url"` | no |
| <a name="input_helm_repository_username"></a> [helm\_repository\_username](#input\_helm\_repository\_username) | The Username credential for the DEMIS Helm Repository, used if helm\_repository\_source is 'url' | `string` | `""` | no |
| <a name="input_jaeger_max_traces"></a> [jaeger\_max\_traces](#input\_jaeger\_max\_traces) | The maximum number of traces to be kept | `number` | `null` | no |
| <a name="input_jaeger_storage_backend"></a> [jaeger\_storage\_backend](#input\_jaeger\_storage\_backend) | The storage backend for Jaeger | `string` | `null` | no |
| <a name="input_jaeger_ttl_spans"></a> [jaeger\_ttl\_spans](#input\_jaeger\_ttl\_spans) | The time to live for spans stored in Jaeger | `string` | `null` | no |
| <a name="input_kms_encryption_key"></a> [kms\_encryption\_key](#input\_kms\_encryption\_key) | The GCP KMS encryption key for OpenTofu state encryption | `string` | `""` | no |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to the kubeconfig file of the cluster | `string` | `"~/.kube/config"` | no |
| <a name="input_loki_retention_period"></a> [loki\_retention\_period](#input\_loki\_retention\_period) | How long ingested logs are kept before deletion (Go duration, e.g. 168h). | `string` | `"168h"` | no |
| <a name="input_loki_s3_access_key_id"></a> [loki\_s3\_access\_key\_id](#input\_loki\_s3\_access\_key\_id) | The S3 access key id used when loki\_storage\_type is s3. | `string` | `""` | no |
| <a name="input_loki_s3_bucket"></a> [loki\_s3\_bucket](#input\_loki\_s3\_bucket) | Own S3 bucket of Loki (chunks, ruler, admin), created by Loki's bucket Job. | `string` | `"loki"` | no |
| <a name="input_loki_s3_endpoint"></a> [loki\_s3\_endpoint](#input\_loki\_s3\_endpoint) | S3 endpoint (host:port) used when loki\_storage\_type is s3: the own object-storage-service (object-storage-service.<namespace>.svc.cluster.local:8080) or an externally managed SeaweedFS. | `string` | `""` | no |
| <a name="input_loki_s3_force_path_style"></a> [loki\_s3\_force\_path\_style](#input\_loki\_s3\_force\_path\_style) | Use path-style S3 URLs (true for MinIO / non-AWS, false for real AWS S3). | `bool` | `true` | no |
| <a name="input_loki_s3_insecure"></a> [loki\_s3\_insecure](#input\_loki\_s3\_insecure) | Talk to the S3 endpoint over plain HTTP instead of HTTPS (true for the own object-storage-service, the sidecars add mTLS). | `bool` | `false` | no |
| <a name="input_loki_s3_object_lock_days"></a> [loki\_s3\_object\_lock\_days](#input\_loki\_s3\_object\_lock\_days) | Object lock of the Loki objects in days (mode loki\_s3\_object\_lock\_mode), 0 disables it. Only set when the bucket is created; must not outlast loki\_retention\_period. | `number` | `0` | no |
| <a name="input_loki_s3_object_lock_mode"></a> [loki\_s3\_object\_lock\_mode](#input\_loki\_s3\_object\_lock\_mode) | Object lock mode of the Loki objects: COMPLIANCE (nobody can delete before expiry) or GOVERNANCE (bypass possible). | `string` | `"COMPLIANCE"` | no |
| <a name="input_loki_s3_region"></a> [loki\_s3\_region](#input\_loki\_s3\_region) | S3 region used when loki\_storage\_type is s3 (may be empty for MinIO / non-AWS). | `string` | `""` | no |
| <a name="input_loki_s3_secret_access_key"></a> [loki\_s3\_secret\_access\_key](#input\_loki\_s3\_secret\_access\_key) | The S3 secret access key used when loki\_storage\_type is s3. | `string` | `""` | no |
| <a name="input_loki_s3_sse_kms_key_id"></a> [loki\_s3\_sse\_kms\_key\_id](#input\_loki\_s3\_sse\_kms\_key\_id) | KMS key id of the object storage, required for loki\_s3\_sse\_type = "SSE-KMS". | `string` | `""` | no |
| <a name="input_loki_s3_sse_type"></a> [loki\_s3\_sse\_type](#input\_loki\_s3\_sse\_type) | Server-side encryption of the Loki objects by the object storage: none, SSE-S3 (key of the object storage) or SSE-KMS (key from its KMS, loki\_s3\_sse\_kms\_key\_id). | `string` | `"none"` | no |
| <a name="input_loki_storage_type"></a> [loki\_storage\_type](#input\_loki\_storage\_type) | Storage backend for Loki. Options: filesystem (default) or s3 (external object storage). | `string` | `"filesystem"` | no |
| <a name="input_loki_volume"></a> [loki\_volume](#input\_loki\_volume) | PersistentVolumeClaim per monolithic Loki instance (WAL, unflushed chunks). null: ephemeral, lost on restart. | <pre>object({<br/>    storage_class = string<br/>    capacity      = string<br/>  })</pre> | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace that is created for the observability services | `string` | `"observability"` | no |
| <a name="input_object_storage_service_access_key"></a> [object\_storage\_service\_access\_key](#input\_object\_storage\_service\_access\_key) | Access key of the admin identity of the object-storage-service | `string` | `""` | no |
| <a name="input_object_storage_service_secret_key"></a> [object\_storage\_service\_secret\_key](#input\_object\_storage\_service\_secret\_key) | Secret key of the admin identity of the object-storage-service | `string` | `""` | no |
| <a name="input_object_storage_service_sse_passphrase"></a> [object\_storage\_service\_sse\_passphrase](#input\_object\_storage\_service\_sse\_passphrase) | Passphrase the object-storage-service derives the SSE-S3 key from; changing it makes all encrypted objects unreadable | `string` | `""` | no |
| <a name="input_override_stage_name"></a> [override\_stage\_name](#input\_override\_stage\_name) | Override the stage name detected from the cluster labels (local or <cluster>-<region>), used for the stage folder of the active-versions.yaml | `string` | `""` | no |
| <a name="input_postgres_root_ca_certificate"></a> [postgres\_root\_ca\_certificate](#input\_postgres\_root\_ca\_certificate) | Base64 encoded CA certificate, pgbouncer verifies the postgres server against it | `string` | `""` | no |
| <a name="input_postgres_server_certificate"></a> [postgres\_server\_certificate](#input\_postgres\_server\_certificate) | Base64 encoded TLS certificate of the postgres server | `string` | `""` | no |
| <a name="input_postgres_server_key"></a> [postgres\_server\_key](#input\_postgres\_server\_key) | Base64 encoded TLS key of the postgres server | `string` | `""` | no |
| <a name="input_project_feature_flags"></a> [project\_feature\_flags](#input\_project\_feature\_flags) | Project feature flags: FEATURE\_FLAG\_OBSERVABILITY\_NAMESPACE\_ENABLED switches from the legacy observability in the infrastructure to this module (same value as in the infrastructure), FEATURE\_FLAG\_AUDIT\_LOG\_FSSR\_ENABLED / FEATURE\_FLAG\_AUDIT\_LOG\_FSSW\_ENABLED switch the Audit Log Service | `map(bool)` | `{}` | no |
| <a name="input_prometheus_service_url"></a> [prometheus\_service\_url](#input\_prometheus\_service\_url) | URL of Prometheus for Kiali, null for the Prometheus of this namespace (if deployed); Grafana only uses the Prometheus of this namespace | `string` | `null` | no |
| <a name="input_resource_definitions"></a> [resource\_definitions](#input\_resource\_definitions) | Replicas, container resources and Istio proxy resources per workload of the namespace (resources.tfvars).<br/>  Workloads without entry keep the module defaults; resources are merged into the chart defaults.<br/>  Services: the components of the active-versions.yaml, additionally kube-state-metrics and prometheus-node-exporter.<br/>  replicas of prometheus-node-exporter (DaemonSet) and audit-log-purger (CronJob) is ignored; jaeger, prometheus, object-storage-service and<br/>  postgres run with one instance (local storage). | <pre>list(object({<br/>    service  = string<br/>    replicas = number<br/>    resources = optional(object({<br/>      limits   = optional(map(string))<br/>      requests = optional(map(string))<br/>    }))<br/>    istio_proxy_resources = optional(object({<br/>      limits   = optional(map(string))<br/>      requests = optional(map(string))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_timeout_retry_overrides"></a> [timeout\_retry\_overrides](#input\_timeout\_retry\_overrides) | Timeout and retry overrides per workload of the namespace (timeout\_retry\_overrides.tfvars), merged over the built-in defaults. Services: object-storage-service. | <pre>list(object({<br/>    service = string<br/>    timeout = optional(string)<br/>    retries = optional(object({<br/>      enable        = optional(bool)<br/>      attempts      = optional(number)<br/>      perTryTimeout = optional(string)<br/>      retryOn       = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_tracing_service_port"></a> [tracing\_service\_port](#input\_tracing\_service\_port) | gRPC query port of Jaeger for Kiali, null for the port of the Jaeger of this namespace (16685) | `string` | `null` | no |
| <a name="input_tracing_service_url"></a> [tracing\_service\_url](#input\_tracing\_service\_url) | Cluster-internal gRPC query URL of Jaeger for Kiali, null for the Jaeger of this namespace (if deployed) | `string` | `null` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | Defines the volumes of the observability namespace: postgres-volume-claim (postgres), object-storage-volume-claim (object-storage-service). The Loki volumes come from its StatefulSet (loki\_volume). | <pre>map(object({<br/>    storage_class = string<br/>    capacity      = string<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_kms_encryption_key_used"></a> [kms\_encryption\_key\_used](#output\_kms\_encryption\_key\_used) | The flag to indicate if the KMS encryption key is used |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace of the observability services |
| <a name="output_url_grafana"></a> [url\_grafana](#output\_url\_grafana) | Grafana URL of Kiali (set from outside or of this namespace), null if none |
| <a name="output_url_jaeger"></a> [url\_jaeger](#output\_url\_jaeger) | Cluster-internal Jaeger UI URL, null if not deployed |
| <a name="output_url_kiali"></a> [url\_kiali](#output\_url\_kiali) | Cluster-internal Kiali URL, null if not deployed |
| <a name="output_url_loki"></a> [url\_loki](#output\_url\_loki) | Cluster-internal Loki URL (the password protected gateway if enabled), null if not deployed |
| <a name="output_url_prometheus"></a> [url\_prometheus](#output\_url\_prometheus) | Prometheus URL of Kiali (set from outside or of this namespace), null if none |
<!-- END_TF_DOCS -->
