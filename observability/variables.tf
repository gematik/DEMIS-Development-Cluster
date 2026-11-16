variable "kubeconfig_path" {
  description = "Path to the kubeconfig file of the cluster"
  type        = string
  default     = "~/.kube/config"
}

variable "kms_encryption_key" {
  description = "The GCP KMS encryption key for OpenTofu state encryption"
  type        = string
  default     = ""
  validation {
    condition     = length(var.kms_encryption_key) > 0 ? startswith(var.kms_encryption_key, "projects/") : true
    error_message = "Invalid KMS encryption key format, must start with 'projects/...'"
  }
}

variable "override_stage_name" {
  description = "Override the stage name detected from the cluster labels (local or <cluster>-<region>), used for the stage folder of the active-versions.yaml"
  type        = string
  default     = ""
}

variable "helm_repository_source" {
  description = "Where Helm Charts are resolved from: 'url' uses the public repository URLs and demis_helm_repository, 'local' uses the repository names from helm_repository_names in the Helm repositories.yaml"
  type        = string
  default     = "url"
  validation {
    condition     = contains(["url", "local"], var.helm_repository_source)
    error_message = "helm_repository_source must be either 'url' or 'local'"
  }
}

variable "helm_repository_names" {
  type = object({
    kiali      = optional(string, "kiali")
    prometheus = optional(string, "prometheus-community")
    loki       = optional(string, "grafana-community")
    demis      = optional(string, "demis")
  })
  description = "Repository names in the Helm repositories.yaml per chart, used if helm_repository_source is 'local'"
  default     = {}
}

variable "demis_helm_repository" {
  type        = string
  default     = null
  description = "Helm Repository URL of the DEMIS charts (Audit Log Service, istio-routing), used if helm_repository_source is 'url'"
}

variable "project_feature_flags" {
  type        = map(bool)
  description = "Project feature flags: FEATURE_FLAG_OBSERVABILITY_NAMESPACE_ENABLED switches from the legacy observability in the infrastructure to this module (same value as in the infrastructure), FEATURE_FLAG_AUDIT_LOG_FSSR_ENABLED / FEATURE_FLAG_AUDIT_LOG_FSSW_ENABLED switch the Audit Log Service"
  default     = {}
}

variable "namespace" {
  description = "Namespace that is created for the observability services (Prometheus, Grafana, Loki; Kiali and Jaeger if kiali_jaeger_in_namespace)"
  type        = string
  default     = "observability"
}

variable "fallback_namespace" {
  description = "Namespace used if the namespace is not needed (no monitoring, no Audit Log Service, Kiali and Jaeger not moved), and for Kiali and Jaeger unless kiali_jaeger_in_namespace"
  type        = string
  default     = "istio-system"
}

variable "loki_storage_type" {
  description = "Storage backend for Loki. Options: filesystem (default) or s3 (external object storage)."
  type        = string
  default     = "filesystem"
}

variable "loki_deployment_mode" {
  description = "Loki deployment topology. Options: Monolithic (default) or SimpleScalable (requires s3 storage)."
  type        = string
  default     = "Monolithic"
}

variable "loki_s3_endpoint" {
  description = "S3 endpoint host used when loki_storage_type is s3."
  type        = string
  default     = ""
}

variable "loki_s3_region" {
  description = "S3 region used when loki_storage_type is s3 (may be empty for MinIO / non-AWS)."
  type        = string
  default     = ""
}

variable "loki_s3_bucket_chunks" {
  description = "S3 bucket for Loki chunks."
  type        = string
  default     = ""
}

variable "loki_s3_bucket_ruler" {
  description = "S3 bucket for Loki ruler rules."
  type        = string
  default     = ""
}

variable "loki_s3_bucket_admin" {
  description = "S3 bucket for Loki admin/compactor objects."
  type        = string
  default     = ""
}

variable "loki_s3_force_path_style" {
  description = "Use path-style S3 URLs (true for MinIO / non-AWS, false for real AWS S3)."
  type        = bool
  default     = true
}

variable "loki_s3_insecure" {
  description = "Talk to the S3 endpoint over plain HTTP instead of HTTPS."
  type        = bool
  default     = false
}

variable "loki_replicas" {
  description = "Number of Loki instances. Must be 1 for filesystem storage; values > 1 require S3 storage. In SimpleScalable mode this is the default for the read/write/backend targets unless overridden."
  type        = number
  default     = 1
}

variable "loki_read_replicas" {
  description = "Replica count for the SimpleScalable read target. Defaults to loki_replicas when not set."
  type        = number
  default     = null
}

variable "loki_write_replicas" {
  description = "Replica count for the SimpleScalable write target. Defaults to loki_replicas when not set."
  type        = number
  default     = null
}

variable "loki_backend_replicas" {
  description = "Replica count for the SimpleScalable backend target. Defaults to loki_replicas when not set."
  type        = number
  default     = null
}

variable "loki_retention_period" {
  description = "How long ingested logs are kept before deletion (Go duration, e.g. 168h)."
  type        = string
  default     = "168h"
}

variable "prometheus_service_url" {
  description = "The Cluster-internal URL of the Prometheus Instance to be used"
  type        = string
  default     = "http://prometheus:9090"
}

variable "tracing_service_url" {
  description = "The Cluster-internal URL of the Tracing Instance to be used"
  type        = string
  default     = "http://tracing:16685/jaeger"
}

variable "grafana_service_url" {
  description = "The Cluster-internal URL of the Grafana Instance to be used"
  type        = string
  default     = "http://grafana:3000"
}

variable "grafana_public_url" {
  description = "The Public URL for Grafana (Used in Kiali as link, if activated)"
  type        = string
  default     = "http://localhost:3000"
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

variable "audit_log_service_docker_registry" {
  description = "Docker registry of the Audit Log Service image"
  type        = string
  default     = "europe-west3-docker.pkg.dev/gematik-all-infra-prod/demis-dev"
}

variable "audit_log_service_replica_count" {
  description = "Number of Audit Log Service replicas"
  type        = number
  default     = 1
}

variable "audit_log_service_audited_namespace" {
  description = "Namespace of the audited workloads (fhir-storage-reader/-writer)"
  type        = string
  default     = "demis"
}
