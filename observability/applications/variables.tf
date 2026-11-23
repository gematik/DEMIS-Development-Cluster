variable "demis_helm_repository" {
  description = "Helm repository of the DEMIS charts (name from the repositories.yaml or URL)"
  type        = string
}

variable "deployment_information" {
  description = "Deployment information of the components from the active-versions.yaml (canary handed over as main), a component is deployed if enabled; empty without the observability namespace"
  type        = any
}

variable "docker_registry" {
  description = "Docker registry of the DEMIS images (Audit Log Service, object-storage-service, postgres, pgbouncer)"
  type        = string
  default     = "europe-west3-docker.pkg.dev/gematik-all-infra-prod/demis-dev"
  validation {
    condition     = strcontains(var.docker_registry, "docker.io/gematik1") || startswith(var.docker_registry, "europe-west3-docker.pkg.dev/gematik-all-infra-prod/demis")
    error_message = "Unsupported Docker Registry provided"
  }
}

variable "project_feature_flags" {
  description = "Project feature flags of the stage"
  type        = map(bool)
  default     = {}
}

variable "helm_repository_by_key" {
  description = "Helm repository name per third-party chart (kiali, prometheus, loki) or null for the module default URL"
  type        = map(string)
}

variable "pull_secrets" {
  description = "Names of the image pull secrets of the DEMIS images"
  type        = list(string)
  default     = []
}

variable "target_namespace" {
  description = "Namespace of the components (observability, or the fallback namespace)"
  type        = string
}

variable "volume_claims" {
  description = "Names of the PersistentVolumeClaims of the root module (volumes) by key"
  type        = map(string)
  default     = {}
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

variable "resource_definitions" {
  description = "Replicas, resource block and Istio proxy resources per workload (output of the resources module, resources.tfvars)"
  type        = any
}

variable "feature_flags" {
  description = "Feature flags per service (feature_flags.tfvars, evaluated by the root module)"
  type        = map(map(bool))
  default     = {}
}

variable "config_options" {
  description = "Config options per service (config_options.tfvars, evaluated by the root module)"
  type        = map(map(string))
  default     = {}
}

variable "timeout_retry_overrides" {
  description = "Timeout and retry overrides per workload of the namespace (timeout_retry_overrides.tfvars), merged over the built-in defaults. Services: object-storage-service."
  type = list(object({
    service = string
    timeout = optional(string)
    retries = optional(object({
      enable        = optional(bool)
      attempts      = optional(number)
      perTryTimeout = optional(string)
      retryOn       = optional(string)
    }))
  }))
  default = []

  validation {
    condition     = alltrue([for conf in var.timeout_retry_overrides : contains(["object-storage-service"], conf.service)])
    error_message = "Timeouts and retries can only be set for the object-storage-service, the only HTTP service with a VirtualService (Loki uses the Istio defaults, postgres and pgbouncer are TCP, the audit-log-service is called by ext_proc without route)."
  }
}

variable "loki_retention_period" {
  description = "How long ingested logs are kept before the compactor deletes them (Go duration, e.g. 24h, 168h, 720h)."
  type        = string
  default     = "168h"
  validation {
    condition     = can(regex("^[0-9]+[smhd]$", var.loki_retention_period))
    error_message = "The loki_retention_period must be a valid Go duration (e.g. 24h, 168h)."
  }
}

variable "loki_storage_type" {
  description = "Storage backend for Loki chunks/indexes. Options: \"filesystem\" (local disk, default) or \"s3\" (external S3-compatible object storage, required for more than one replica)."
  type        = string
  default     = "filesystem"
  validation {
    condition     = contains(["filesystem", "s3"], var.loki_storage_type)
    error_message = "The loki_storage_type must be either \"filesystem\" or \"s3\"."
  }
}

variable "loki_volume" {
  description = "PersistentVolumeClaim per monolithic Loki instance (WAL, unflushed chunks). null: ephemeral, lost on restart."
  type = object({
    storage_class = string
    capacity      = string
  })
  default = null
}

variable "loki_s3_bucket" {
  description = "Own S3 bucket of Loki for chunks, ruler rules and admin/compactor objects (used when loki_storage_type is \"s3\"). Created by the bucket Job of this module."
  type        = string
  default     = "loki"
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.loki_s3_bucket))
    error_message = "The loki_s3_bucket must be a valid S3 bucket name."
  }
}

variable "loki_s3_endpoint" {
  description = "S3 endpoint (host:port) used when loki_storage_type is s3: the own object-storage-service (object-storage-service.<namespace>.svc.cluster.local:8080) or an externally managed SeaweedFS."
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

variable "loki_s3_object_lock_days" {
  description = "Object lock of every object in the Loki bucket in days (mode loki_s3_object_lock_mode), 0 disables object lock. Can only be enabled when the bucket is created."
  type        = number
  default     = 0
  validation {
    condition     = var.loki_s3_object_lock_days >= 0 && floor(var.loki_s3_object_lock_days) == var.loki_s3_object_lock_days
    error_message = "The loki_s3_object_lock_days must be a whole number >= 0."
  }
}

variable "loki_s3_object_lock_mode" {
  description = "Object lock mode: \"COMPLIANCE\" (nobody can delete or shorten the lock before it expires, not even an admin) or \"GOVERNANCE\" (identities with the bypass right can delete locked objects)."
  type        = string
  default     = "COMPLIANCE"
  validation {
    condition     = contains(["COMPLIANCE", "GOVERNANCE"], var.loki_s3_object_lock_mode)
    error_message = "The loki_s3_object_lock_mode must be either \"COMPLIANCE\" or \"GOVERNANCE\"."
  }
}

variable "loki_s3_region" {
  description = "S3 region used when loki_storage_type is s3 (may be empty for MinIO / non-AWS)."
  type        = string
  default     = ""
}

variable "loki_s3_sse_kms_key_id" {
  description = "KMS key id of the object storage, required for loki_s3_sse_type = \"SSE-KMS\"."
  type        = string
  default     = ""
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

# Used only to establish apply-time ordering: maintenance mode must be activated before
# services are deployed. Passed as a direct input instead of depends_on to avoid the
# "known after apply" propagation that module-level depends_on causes.
# tflint-ignore: terraform_unused_declarations
variable "maintenance_mode_trigger" {
  type        = string
  description = "Output from module.activate_maintenance_mode that establishes deploy ordering without known-after-apply propagation."
  default     = ""
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

variable "external_chart_path" {
  description = "The path to the stage-dependent Helm Chart Values."
  type        = string
  validation {
    condition     = length(var.external_chart_path) > 0
    error_message = "The path to the stage-dependent Helm Chart Values must be defined"
  }
}

# Debugging
variable "debug_enabled" {
  type        = bool
  description = "Defines if the backend Java Services must be started in Debug Mode"
  default     = false
}
