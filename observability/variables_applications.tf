#########################
# Application Configuration
#########################

variable "loki_storage_type" {
  description = "Storage backend for Loki. Options: filesystem (default) or s3 (external object storage)."
  type        = string
  default     = "filesystem"
}

variable "loki_s3_endpoint" {
  description = "S3 endpoint (host:port) used when loki_storage_type is s3: the own object-storage-service (object-storage-service.<namespace>.svc.cluster.local:8080) or an externally managed SeaweedFS."
  type        = string
  default     = ""
}

variable "loki_s3_region" {
  description = "S3 region used when loki_storage_type is s3 (may be empty for MinIO / non-AWS)."
  type        = string
  default     = ""
}

variable "loki_s3_bucket" {
  description = "Own S3 bucket of Loki (chunks, ruler, admin), created by Loki's bucket Job."
  type        = string
  default     = "loki"
}

variable "loki_s3_object_lock_days" {
  description = "Object lock of the Loki objects in days (mode loki_s3_object_lock_mode), 0 disables it. Only set when the bucket is created; must not outlast loki_retention_period."
  type        = number
  default     = 0
}

variable "loki_s3_object_lock_mode" {
  description = "Object lock mode of the Loki objects: COMPLIANCE (nobody can delete before expiry) or GOVERNANCE (bypass possible)."
  type        = string
  default     = "COMPLIANCE"
}

variable "loki_s3_sse_type" {
  description = "Server-side encryption of the Loki objects by the object storage: none, SSE-S3 (key of the object storage) or SSE-KMS (key from its KMS, loki_s3_sse_kms_key_id)."
  type        = string
  default     = "none"
  validation {
    condition     = contains(["none", "SSE-S3", "SSE-KMS"], var.loki_s3_sse_type)
    error_message = "The loki_s3_sse_type must be one of \"none\", \"SSE-S3\" or \"SSE-KMS\"."
  }
}

variable "loki_s3_sse_kms_key_id" {
  description = "KMS key id of the object storage, required for loki_s3_sse_type = \"SSE-KMS\"."
  type        = string
  default     = ""
}

variable "loki_s3_force_path_style" {
  description = "Use path-style S3 URLs (true for MinIO / non-AWS, false for real AWS S3)."
  type        = bool
  default     = true
}

variable "loki_s3_insecure" {
  description = "Talk to the S3 endpoint over plain HTTP instead of HTTPS (true for the own object-storage-service, the sidecars add mTLS)."
  type        = bool
  default     = false
}

variable "loki_volume" {
  description = "PersistentVolumeClaim per monolithic Loki instance (WAL, unflushed chunks). null: ephemeral, lost on restart."
  type = object({
    storage_class = string
    capacity      = string
  })
  default = null
}

variable "loki_retention_period" {
  description = "How long ingested logs are kept before deletion (Go duration, e.g. 168h)."
  type        = string
  default     = "168h"
}

variable "prometheus_service_url" {
  description = "URL of Prometheus for Kiali, null for the Prometheus of this namespace (if deployed); Grafana only uses the Prometheus of this namespace"
  type        = string
  default     = null
}

variable "tracing_service_url" {
  description = "Cluster-internal gRPC query URL of Jaeger for Kiali, null for the Jaeger of this namespace (if deployed)"
  type        = string
  default     = null
}

variable "tracing_service_port" {
  description = "gRPC query port of Jaeger for Kiali, null for the port of the Jaeger of this namespace (16685)"
  type        = string
  default     = null
}

variable "grafana_service_url" {
  description = "Cluster-internal URL of Grafana for Kiali, null for the Grafana of this namespace (if deployed)"
  type        = string
  default     = null
}

variable "grafana_public_url" {
  description = "Public URL of Grafana, the link in Kiali; null for the one of the Grafana of this namespace (if deployed)"
  type        = string
  default     = null
}

variable "jaeger_max_traces" {
  description = "The maximum number of traces to be kept"
  type        = number
  default     = null
  nullable    = true
}

variable "jaeger_ttl_spans" {
  description = "The time to live for spans stored in Jaeger"
  type        = string
  default     = null
  nullable    = true
}

variable "jaeger_storage_backend" {
  description = "The storage backend for Jaeger"
  type        = string
  default     = null
  nullable    = true
}

variable "audit_log_service_audited_namespaces" {
  description = "Namespaces audited by the Audit Log Service per layer (one observability namespace audits several namespaces); the filters per layer are defined in the chart values template"
  type = object({
    demis = optional(list(string), ["demis"])
    dmz   = optional(list(string), [])
    are   = optional(list(string), [])
  })
  default = {}
}

variable "audit_log_purger_suspend" {
  description = "Defines if the CronJob of the audit-log-purger is suspended"
  type        = bool
  default     = false
}

variable "audit_log_purger_cron_schedule" {
  description = "Cron schedule of the audit-log-purger"
  type        = string
  default     = "0 22 * * *"
  validation {
    condition     = length(var.audit_log_purger_cron_schedule) > 0
    error_message = "The audit-log-purger cron schedule must be defined"
  }
}

# Debugging
variable "debug_enabled" {
  type        = bool
  description = "Defines if the backend Java Services must be started in Debug Mode"
  default     = false
}
