# loki

Module to deploy a Loki instance as central log receiver (Monolithic single-binary, scaled out with S3; replicas and resources in `resource_definitions`). The chart is pulled from the grafana-community OCI registry (`oci://ghcr.io/grafana-community/helm-charts/loki`). The DEMIS applications actively push their logs to the Loki Push-API (`<loki_service_url>/loki/api/v1/push`); no log collector (Promtail/Alloy) is deployed. Loki is only rolled out together with Grafana.

Storage is `filesystem` (local disk, default) or `s3`, an S3-compatible object storage such as the object-storage-service. S3 credentials are injected as sensitive Helm values and never written into the chart values file.

With `filesystem` all logs live on the PVC (`loki_volume`) of the single instance: size it for `loki_retention_period` times the daily log volume, a full volume stops flushes and the retention. Switching an existing installation from `filesystem` to `s3` starts with an empty store; the logs on the PVC are no longer queried (one schema period for both).

With `s3`:

- **Own bucket**: a Job (`loki-bucket-<hash>`, service account `loki-bucket`) creates `loki_s3_bucket` and (re)applies its configuration:
  - object lock (`loki_s3_object_lock_mode`, default COMPLIANCE) for `loki_s3_object_lock_days` (must not outlast `loki_retention_period`), plus lifecycle rules removing deleted (noncurrent) versions one day later, never before their lock expired, and the delete markers left without any version. SeaweedFS executes lifecycle rules of versioned buckets only with a running `weed worker`
  - default encryption by `loki_s3_sse_type`: `none` (removes an existing default encryption, objects written before stay encrypted), `SSE-S3` (the object storage derives the key from its passphrase, `object_storage_service_sse_passphrase` of the object-storage-service in the observability namespace) or `SSE-KMS` (key `loki_s3_sse_kms_key_id` from the KMS of the object storage; the own object-storage-service has no KMS)

  Object lock can only be enabled when the bucket is created: on an existing bucket without lock the Job fails, the bucket has to be removed first. The object storage must be reachable: the root module deploys the own object-storage-service of the namespace before Loki; otherwise `loki_s3_endpoint` points to an externally managed SeaweedFS.
- **Retention**: after `loki_retention_period` the next compactor run marks the logs for deletion (removed from the index, no longer queryable) and deletes them after the delete delay. With object lock the deletes only add delete markers, the locked versions stay until the lock expires and are removed by the lifecycle rules.
- **Access control**: no gateway and no password. The clients use the `loki` Service on port 3100; the Istio authorization policies of the observability namespace (policies chart) only let the Audit Log Service push, Grafana query and Loki reach itself, based on the mTLS identities (service accounts).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0, < 4.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0.0, < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_job_v1.bucket](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job_v1) | resource |
| [kubernetes_service_account_v1.bucket](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_loki_bucket_job_image"></a> [loki\_bucket\_job\_image](#input\_loki\_bucket\_job\_image) | aws-cli image of the Job creating and configuring the Loki bucket | `string` | `"amazon/aws-cli:2.27.50@sha256:48c3d4212e2f5b0e24bdc6af7708f9412ce65425a79575e0f78b8f8c0dcd70ab"` | no |
| <a name="input_loki_helm_repository"></a> [loki\_helm\_repository](#input\_loki\_helm\_repository) | The Helm Repository to download the Loki Chart | `string` | `"oci://ghcr.io/grafana-community/helm-charts"` | no |
| <a name="input_loki_retention_period"></a> [loki\_retention\_period](#input\_loki\_retention\_period) | How long ingested logs are kept before the compactor deletes them (Go duration, e.g. 24h, 168h, 720h). | `string` | `"168h"` | no |
| <a name="input_loki_s3_access_key_id"></a> [loki\_s3\_access\_key\_id](#input\_loki\_s3\_access\_key\_id) | The S3 access key id used when loki\_storage\_type is "s3". Leave empty to rely on an IAM role / instance profile. | `string` | `""` | no |
| <a name="input_loki_s3_bucket"></a> [loki\_s3\_bucket](#input\_loki\_s3\_bucket) | Own S3 bucket of Loki for chunks, ruler rules and admin/compactor objects (used when loki\_storage\_type is "s3"). Created by the bucket Job of this module. | `string` | `"loki"` | no |
| <a name="input_loki_s3_credentials_secret"></a> [loki\_s3\_credentials\_secret](#input\_loki\_s3\_credentials\_secret) | Secret with the AWS shared credentials file (key credentials) of the Loki identity, mounted into the bucket Job (secrets of the root module) | `string` | `"loki-bucket-credentials"` | no |
| <a name="input_loki_s3_endpoint"></a> [loki\_s3\_endpoint](#input\_loki\_s3\_endpoint) | S3 endpoint host used when loki\_storage\_type is "s3" (e.g. "s3.eu-central-1.amazonaws.com" or a MinIO host). | `string` | `""` | no |
| <a name="input_loki_s3_force_path_style"></a> [loki\_s3\_force\_path\_style](#input\_loki\_s3\_force\_path\_style) | Use path-style S3 URLs. true for MinIO / most non-AWS endpoints, false for real AWS S3. | `bool` | `true` | no |
| <a name="input_loki_s3_insecure"></a> [loki\_s3\_insecure](#input\_loki\_s3\_insecure) | Talk to the S3 endpoint over plain HTTP instead of HTTPS. | `bool` | `false` | no |
| <a name="input_loki_s3_object_lock_days"></a> [loki\_s3\_object\_lock\_days](#input\_loki\_s3\_object\_lock\_days) | Object lock of every object in the Loki bucket in days (mode loki\_s3\_object\_lock\_mode), 0 disables object lock. Can only be enabled when the bucket is created. | `number` | `0` | no |
| <a name="input_loki_s3_object_lock_mode"></a> [loki\_s3\_object\_lock\_mode](#input\_loki\_s3\_object\_lock\_mode) | Object lock mode: "COMPLIANCE" (nobody can delete or shorten the lock before it expires, not even an admin) or "GOVERNANCE" (identities with the bypass right can delete locked objects). | `string` | `"COMPLIANCE"` | no |
| <a name="input_loki_s3_region"></a> [loki\_s3\_region](#input\_loki\_s3\_region) | S3 region used when loki\_storage\_type is "s3" (may be empty for MinIO / non-AWS endpoints). | `string` | `""` | no |
| <a name="input_loki_s3_secret_access_key"></a> [loki\_s3\_secret\_access\_key](#input\_loki\_s3\_secret\_access\_key) | The S3 secret access key used when loki\_storage\_type is "s3". Leave empty to rely on an IAM role / instance profile. | `string` | `""` | no |
| <a name="input_loki_s3_sse_kms_key_id"></a> [loki\_s3\_sse\_kms\_key\_id](#input\_loki\_s3\_sse\_kms\_key\_id) | KMS key id of the object storage, required for loki\_s3\_sse\_type = "SSE-KMS". | `string` | `""` | no |
| <a name="input_loki_s3_sse_type"></a> [loki\_s3\_sse\_type](#input\_loki\_s3\_sse\_type) | Server-side encryption of the Loki objects by the object storage: none, SSE-S3 (key of the object storage) or SSE-KMS (key from its KMS, loki\_s3\_sse\_kms\_key\_id). | `string` | `"none"` | no |
| <a name="input_loki_storage_type"></a> [loki\_storage\_type](#input\_loki\_storage\_type) | Storage backend for Loki chunks/indexes. Options: "filesystem" (local disk, default) or "s3" (external S3-compatible object storage, required for more than one replica). | `string` | `"filesystem"` | no |
| <a name="input_loki_version"></a> [loki\_version](#input\_loki\_version) | The version of Loki to be installed | `string` | n/a | yes |
| <a name="input_loki_volume"></a> [loki\_volume](#input\_loki\_volume) | PersistentVolumeClaim per monolithic Loki instance (WAL, unflushed chunks; with filesystem storage all data). null: ephemeral pod storage, lost on restart. | <pre>object({<br/>    storage_class = string<br/>    capacity      = string<br/>  })</pre> | `null` | no |
| <a name="input_resource_definitions"></a> [resource\_definitions](#input\_resource\_definitions) | Per workload of the module (output of the resources module): replicas, resource block (YAML) and Istio proxy resources; null or missing keeps the defaults | <pre>map(object({<br/>    replicas       = optional(number)<br/>    resource_block = optional(string)<br/>    istio_proxy_resources = optional(object({<br/>      limits   = optional(map(string), {})<br/>      requests = optional(map(string), {})<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_target_namespace"></a> [target\_namespace](#input\_target\_namespace) | Namespace where to install the services | `string` | `"observability"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_loki_otlp_logs_url"></a> [loki\_otlp\_logs\_url](#output\_loki\_otlp\_logs\_url) | The Loki native OTLP logs endpoint (OTLP over HTTP). Applications can push logs<br/>directly via OTLP/HTTP without a collector. Note: Loki only accepts OTLP over HTTP,<br/>there is no OTLP/gRPC log receiver - the gRPC port 9095 is for internal component<br/>traffic only. |
| <a name="output_loki_port"></a> [loki\_port](#output\_loki\_port) | The Loki HTTP port |
| <a name="output_loki_push_url"></a> [loki\_push\_url](#output\_loki\_push\_url) | The Loki native Push-API endpoint (Loki line protocol, HTTP) |
| <a name="output_loki_service_url"></a> [loki\_service\_url](#output\_loki\_service\_url) | The Cluster-internal Loki base URL (host:port for Push-API, OTLP and query endpoints) |
<!-- END_TF_DOCS -->
