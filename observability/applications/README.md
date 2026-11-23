# applications

Components of the observability namespace, as `demis/applications`: the charts (Grafana, Loki, Kiali, Jaeger, Prometheus, object-storage-service, postgres/pgbouncer, Audit Log Service), their secrets (`secrets.tf`) and the HTTP timeouts/retries (`http_timeouts_retries.tf`). Namespace, pull secrets, volumes, feature flags, config options, resources and the Istio policies stay in the root module.

Each component has its `chart-<name>.tf`. The DEMIS charts (audit-log-service, object-storage-service, postgres, pgbouncer) and Prometheus are defined there directly, their folders only hold the templates. Grafana, Kiali, Jaeger and Loki are own modules in their folders (split into files, Loki with unit tests); their `chart-<name>.tf` calls the module.

## audit-log-service

Deploys the Audit Log Service into the observability namespace. Its ext_proc EnvoyFilters are placed in the Istio root namespace and restricted via `proxy.metadata.NAMESPACE` to their audited namespace (the filters of each layer, e.g. fhir-storage-reader/-writer for demis, for every namespace of that layer in `audit_log_service_audited_namespaces`), since those namespaces do not exist yet when the infrastructure is deployed.

## object-storage-service

Deploys the object-storage-service (SeaweedFS, S3) of the observability namespace for Loki: Loki identity restricted to its bucket, SSE-S3 with a passphrase, no anonymous access. Only Loki may reach it (Istio authorization policies of the observability namespace, policies chart).

## postgres

Deploys postgres and pgbouncer of the observability namespace with the database fetched_notifications (Audit Log Service; read by Grafana with the Grafana reader user). postgres only accepts pgbouncer, pgbouncer only Grafana and the Audit Log Service (Istio authorization policies of the observability namespace, policies chart).

## prometheus

Deploys a Prometheus Instance to scrape metrics from running Workloads in the cluster. It activates by the default the scraping of metrics from the DEMIS applications over TLS.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0, < 4.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0.0, < 4.0.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_audit_log_purger"></a> [audit\_log\_purger](#module\_audit\_log\_purger) | ../../modules/helm_deployment | n/a |
| <a name="module_audit_log_service"></a> [audit\_log\_service](#module\_audit\_log\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_grafana"></a> [grafana](#module\_grafana) | ./grafana | n/a |
| <a name="module_http_timeouts_retries"></a> [http\_timeouts\_retries](#module\_http\_timeouts\_retries) | ../../modules/http_timeouts_retries | n/a |
| <a name="module_jaeger"></a> [jaeger](#module\_jaeger) | ./jaeger | n/a |
| <a name="module_kiali"></a> [kiali](#module\_kiali) | ./kiali | n/a |
| <a name="module_loki"></a> [loki](#module\_loki) | ./loki | n/a |
| <a name="module_object_storage_service"></a> [object\_storage\_service](#module\_object\_storage\_service) | ../../modules/helm_deployment | n/a |
| <a name="module_pgbouncer"></a> [pgbouncer](#module\_pgbouncer) | ../../modules/helm_deployment | n/a |
| <a name="module_postgres"></a> [postgres](#module\_postgres) | ../../modules/helm_deployment | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.prometheus](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_cluster_role_binding_v1.prometheus_node_proxy](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding_v1) | resource |
| [kubernetes_cluster_role_v1.prometheus_node_proxy](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_v1) | resource |
| [kubernetes_secret_v1.database_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.loki_s3_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.object_storage_service_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.pgbouncer_userlist](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.postgresql_tls_certificates](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_audit_log_purger_cron_schedule"></a> [audit\_log\_purger\_cron\_schedule](#input\_audit\_log\_purger\_cron\_schedule) | Cron schedule of the audit-log-purger | `string` | `"0 22 * * *"` | no |
| <a name="input_audit_log_purger_suspend"></a> [audit\_log\_purger\_suspend](#input\_audit\_log\_purger\_suspend) | Defines if the CronJob of the audit-log-purger is suspended | `bool` | `false` | no |
| <a name="input_audit_log_service_audited_namespaces"></a> [audit\_log\_service\_audited\_namespaces](#input\_audit\_log\_service\_audited\_namespaces) | Namespaces audited by the Audit Log Service per layer (one observability namespace audits several namespaces); the filters per layer are defined in the chart values template | <pre>object({<br/>    demis = optional(list(string), ["demis"])<br/>    dmz   = optional(list(string), [])<br/>    are   = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_config_options"></a> [config\_options](#input\_config\_options) | Config options per service (config\_options.tfvars, evaluated by the root module) | `map(map(string))` | `{}` | no |
| <a name="input_database_credentials"></a> [database\_credentials](#input\_database\_credentials) | Database credentials of postgres (admin and the fetched\_notifications users), as database\_credentials of the demis module | <pre>list(object({<br/>    username            = string<br/>    password            = string<br/>    secret-name         = string<br/>    secret-key-user     = string<br/>    secret-key-password = string<br/>  }))</pre> | `[]` | no |
| <a name="input_debug_enabled"></a> [debug\_enabled](#input\_debug\_enabled) | Defines if the backend Java Services must be started in Debug Mode | `bool` | `false` | no |
| <a name="input_demis_helm_repository"></a> [demis\_helm\_repository](#input\_demis\_helm\_repository) | Helm repository of the DEMIS charts (name from the repositories.yaml or URL) | `string` | n/a | yes |
| <a name="input_demis_helm_repository_password"></a> [demis\_helm\_repository\_password](#input\_demis\_helm\_repository\_password) | Password of the DEMIS Helm repository (null for a local repository) | `string` | `null` | no |
| <a name="input_demis_helm_repository_username"></a> [demis\_helm\_repository\_username](#input\_demis\_helm\_repository\_username) | Username of the DEMIS Helm repository (null for a local repository) | `string` | `null` | no |
| <a name="input_deployment_information"></a> [deployment\_information](#input\_deployment\_information) | Deployment information of the components from the active-versions.yaml (canary handed over as main), a component is deployed if enabled; empty without the observability namespace | `any` | n/a | yes |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | Docker registry of the DEMIS images (Audit Log Service, object-storage-service, postgres, pgbouncer) | `string` | `"europe-west3-docker.pkg.dev/gematik-all-infra-prod/demis-dev"` | no |
| <a name="input_external_chart_path"></a> [external\_chart\_path](#input\_external\_chart\_path) | The path to the stage-dependent Helm Chart Values. | `string` | n/a | yes |
| <a name="input_feature_flags"></a> [feature\_flags](#input\_feature\_flags) | Feature flags per service (feature\_flags.tfvars, evaluated by the root module) | `map(map(bool))` | `{}` | no |
| <a name="input_grafana_public_url"></a> [grafana\_public\_url](#input\_grafana\_public\_url) | Public URL of Grafana, the link in Kiali; null for the one of the Grafana of this namespace (if deployed) | `string` | `null` | no |
| <a name="input_grafana_service_url"></a> [grafana\_service\_url](#input\_grafana\_service\_url) | Cluster-internal URL of Grafana for Kiali, null for the Grafana of this namespace (if deployed) | `string` | `null` | no |
| <a name="input_helm_repository_by_key"></a> [helm\_repository\_by\_key](#input\_helm\_repository\_by\_key) | Helm repository name per third-party chart (kiali, prometheus, loki) or null for the module default URL | `map(string)` | n/a | yes |
| <a name="input_jaeger_max_traces"></a> [jaeger\_max\_traces](#input\_jaeger\_max\_traces) | The maximum number of traces to be kept | `number` | `null` | no |
| <a name="input_jaeger_storage_backend"></a> [jaeger\_storage\_backend](#input\_jaeger\_storage\_backend) | The storage backend for Jaeger | `string` | `null` | no |
| <a name="input_jaeger_ttl_spans"></a> [jaeger\_ttl\_spans](#input\_jaeger\_ttl\_spans) | The time to live for spans stored in Jaeger | `string` | `null` | no |
| <a name="input_loki_retention_period"></a> [loki\_retention\_period](#input\_loki\_retention\_period) | How long ingested logs are kept before the compactor deletes them (Go duration, e.g. 24h, 168h, 720h). | `string` | `"168h"` | no |
| <a name="input_loki_s3_access_key_id"></a> [loki\_s3\_access\_key\_id](#input\_loki\_s3\_access\_key\_id) | The S3 access key id used when loki\_storage\_type is s3. | `string` | `""` | no |
| <a name="input_loki_s3_bucket"></a> [loki\_s3\_bucket](#input\_loki\_s3\_bucket) | Own S3 bucket of Loki for chunks, ruler rules and admin/compactor objects (used when loki\_storage\_type is "s3"). Created by the bucket Job of this module. | `string` | `"loki"` | no |
| <a name="input_loki_s3_endpoint"></a> [loki\_s3\_endpoint](#input\_loki\_s3\_endpoint) | S3 endpoint (host:port) used when loki\_storage\_type is s3: the own object-storage-service (object-storage-service.<namespace>.svc.cluster.local:8080) or an externally managed SeaweedFS. | `string` | `""` | no |
| <a name="input_loki_s3_force_path_style"></a> [loki\_s3\_force\_path\_style](#input\_loki\_s3\_force\_path\_style) | Use path-style S3 URLs (true for MinIO / non-AWS, false for real AWS S3). | `bool` | `true` | no |
| <a name="input_loki_s3_insecure"></a> [loki\_s3\_insecure](#input\_loki\_s3\_insecure) | Talk to the S3 endpoint over plain HTTP instead of HTTPS (true for the own object-storage-service, the sidecars add mTLS). | `bool` | `false` | no |
| <a name="input_loki_s3_object_lock_days"></a> [loki\_s3\_object\_lock\_days](#input\_loki\_s3\_object\_lock\_days) | Object lock of every object in the Loki bucket in days (mode loki\_s3\_object\_lock\_mode), 0 disables object lock. Can only be enabled when the bucket is created. | `number` | `0` | no |
| <a name="input_loki_s3_object_lock_mode"></a> [loki\_s3\_object\_lock\_mode](#input\_loki\_s3\_object\_lock\_mode) | Object lock mode: "COMPLIANCE" (nobody can delete or shorten the lock before it expires, not even an admin) or "GOVERNANCE" (identities with the bypass right can delete locked objects). | `string` | `"COMPLIANCE"` | no |
| <a name="input_loki_s3_region"></a> [loki\_s3\_region](#input\_loki\_s3\_region) | S3 region used when loki\_storage\_type is s3 (may be empty for MinIO / non-AWS). | `string` | `""` | no |
| <a name="input_loki_s3_secret_access_key"></a> [loki\_s3\_secret\_access\_key](#input\_loki\_s3\_secret\_access\_key) | The S3 secret access key used when loki\_storage\_type is s3. | `string` | `""` | no |
| <a name="input_loki_s3_sse_kms_key_id"></a> [loki\_s3\_sse\_kms\_key\_id](#input\_loki\_s3\_sse\_kms\_key\_id) | KMS key id of the object storage, required for loki\_s3\_sse\_type = "SSE-KMS". | `string` | `""` | no |
| <a name="input_loki_s3_sse_type"></a> [loki\_s3\_sse\_type](#input\_loki\_s3\_sse\_type) | Server-side encryption of the Loki objects by the object storage: none, SSE-S3 (key of the object storage) or SSE-KMS (key from its KMS, loki\_s3\_sse\_kms\_key\_id). | `string` | `"none"` | no |
| <a name="input_loki_storage_type"></a> [loki\_storage\_type](#input\_loki\_storage\_type) | Storage backend for Loki chunks/indexes. Options: "filesystem" (local disk, default) or "s3" (external S3-compatible object storage, required for more than one replica). | `string` | `"filesystem"` | no |
| <a name="input_loki_volume"></a> [loki\_volume](#input\_loki\_volume) | PersistentVolumeClaim per monolithic Loki instance (WAL, unflushed chunks). null: ephemeral, lost on restart. | <pre>object({<br/>    storage_class = string<br/>    capacity      = string<br/>  })</pre> | `null` | no |
| <a name="input_maintenance_mode_trigger"></a> [maintenance\_mode\_trigger](#input\_maintenance\_mode\_trigger) | Output from module.activate\_maintenance\_mode that establishes deploy ordering without known-after-apply propagation. | `string` | `""` | no |
| <a name="input_object_storage_service_access_key"></a> [object\_storage\_service\_access\_key](#input\_object\_storage\_service\_access\_key) | Access key of the admin identity of the object-storage-service | `string` | `""` | no |
| <a name="input_object_storage_service_secret_key"></a> [object\_storage\_service\_secret\_key](#input\_object\_storage\_service\_secret\_key) | Secret key of the admin identity of the object-storage-service | `string` | `""` | no |
| <a name="input_object_storage_service_sse_passphrase"></a> [object\_storage\_service\_sse\_passphrase](#input\_object\_storage\_service\_sse\_passphrase) | Passphrase the object-storage-service derives the SSE-S3 key from; changing it makes all encrypted objects unreadable | `string` | `""` | no |
| <a name="input_postgres_root_ca_certificate"></a> [postgres\_root\_ca\_certificate](#input\_postgres\_root\_ca\_certificate) | Base64 encoded CA certificate, pgbouncer verifies the postgres server against it | `string` | `""` | no |
| <a name="input_postgres_server_certificate"></a> [postgres\_server\_certificate](#input\_postgres\_server\_certificate) | Base64 encoded TLS certificate of the postgres server | `string` | `""` | no |
| <a name="input_postgres_server_key"></a> [postgres\_server\_key](#input\_postgres\_server\_key) | Base64 encoded TLS key of the postgres server | `string` | `""` | no |
| <a name="input_project_feature_flags"></a> [project\_feature\_flags](#input\_project\_feature\_flags) | Project feature flags of the stage | `map(bool)` | `{}` | no |
| <a name="input_prometheus_service_url"></a> [prometheus\_service\_url](#input\_prometheus\_service\_url) | URL of Prometheus for Kiali, null for the Prometheus of this namespace (if deployed); Grafana only uses the Prometheus of this namespace | `string` | `null` | no |
| <a name="input_pull_secrets"></a> [pull\_secrets](#input\_pull\_secrets) | Names of the image pull secrets of the DEMIS images | `list(string)` | `[]` | no |
| <a name="input_resource_definitions"></a> [resource\_definitions](#input\_resource\_definitions) | Replicas, resource block and Istio proxy resources per workload (output of the resources module, resources.tfvars) | `any` | n/a | yes |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | Namespace of the components (observability, or the fallback namespace) | `string` | n/a | yes |
| <a name="input_timeout_retry_overrides"></a> [timeout\_retry\_overrides](#input\_timeout\_retry\_overrides) | Timeout and retry overrides per workload of the namespace (timeout\_retry\_overrides.tfvars), merged over the built-in defaults. Services: object-storage-service. | <pre>list(object({<br/>    service = string<br/>    timeout = optional(string)<br/>    retries = optional(object({<br/>      enable        = optional(bool)<br/>      attempts      = optional(number)<br/>      perTryTimeout = optional(string)<br/>      retryOn       = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_tracing_service_port"></a> [tracing\_service\_port](#input\_tracing\_service\_port) | gRPC query port of Jaeger for Kiali, null for the port of the Jaeger of this namespace (16685) | `string` | `null` | no |
| <a name="input_tracing_service_url"></a> [tracing\_service\_url](#input\_tracing\_service\_url) | Cluster-internal gRPC query URL of Jaeger for Kiali, null for the Jaeger of this namespace (if deployed) | `string` | `null` | no |
| <a name="input_volume_claims"></a> [volume\_claims](#input\_volume\_claims) | Names of the PersistentVolumeClaims of the root module (volumes) by key | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_audit_log_purger_enabled"></a> [audit\_log\_purger\_enabled](#output\_audit\_log\_purger\_enabled) | Whether the audit-log-purger is enabled |
| <a name="output_audit_log_purger_version"></a> [audit\_log\_purger\_version](#output\_audit\_log\_purger\_version) | Chart version of the audit-log-purger, empty if not deployed |
| <a name="output_url_grafana"></a> [url\_grafana](#output\_url\_grafana) | Grafana URL of Kiali (set from outside or of this namespace), null if none |
| <a name="output_url_jaeger"></a> [url\_jaeger](#output\_url\_jaeger) | Cluster-internal Jaeger UI URL, null if not deployed |
| <a name="output_url_kiali"></a> [url\_kiali](#output\_url\_kiali) | Cluster-internal Kiali URL, null if not deployed |
| <a name="output_url_loki"></a> [url\_loki](#output\_url\_loki) | Cluster-internal Loki URL, null if not deployed |
| <a name="output_url_prometheus"></a> [url\_prometheus](#output\_url\_prometheus) | Prometheus URL of Kiali (set from outside or of this namespace), null if none |
<!-- END_TF_DOCS -->
