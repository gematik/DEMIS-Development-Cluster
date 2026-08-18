#########################
# Service Mesh Module
#########################

variable "service_mesh_namespace" {
  type        = string
  default     = "istio-system"
  description = "Defines the namespace for the Service Mesh services (Istio, Jaeger, Kiali)"
  validation {
    condition     = length(var.service_mesh_namespace) > 0
    error_message = "The Service Mesh namespace must not be empty"
  }
}

variable "service_mesh_istio_version" {
  type        = string
  description = "The version of the Istio Helm Chart to be installed."
  validation {
    condition     = length(var.service_mesh_istio_version) > 0
    error_message = "The Istio version must not be empty"
  }
}

variable "service_mesh_kiali_version" {
  type        = string
  description = "The version of the Kiali to be installed."
  validation {
    condition     = length(var.service_mesh_kiali_version) > 0
    error_message = "The Kiali version must not be empty"
  }
}

variable "service_mesh_jaeger_version" {
  type        = string
  description = "The version of Jaeger to be installed."
  validation {
    condition     = length(var.service_mesh_jaeger_version) > 0
    error_message = "The Jaeger version must not be empty"
  }
}

variable "service_mesh_jaeger_digest" {
  description = "The digest of the Jaeger Service to be used"
  type        = string
  validation {
    condition     = length(var.service_mesh_jaeger_digest) > 0 && startswith(var.service_mesh_jaeger_digest, "sha256:")
    error_message = "The Jaeger digest must not be empty and must start with 'sha256:'"
  }
}

variable "service_mesh_grafana_version" {
  type        = string
  description = "The version of Grafana to be installed."
  default     = ""
}

variable "service_mesh_grafana_digest" {
  description = "The digest of the Grafana Service to be used"
  type        = string
  default     = ""
  validation {
    condition     = length(var.service_mesh_grafana_digest) > 0 ? startswith(var.service_mesh_grafana_digest, "sha256:") : true
    error_message = "The Grafana digest must not be empty and must start with 'sha256:'"
  }
}

variable "service_mesh_prometheus_version" {
  type        = string
  description = "The version of Prometheus to be installed."
  default     = ""
}

variable "service_mesh_loki_enabled" {
  type        = bool
  default     = false
  description = "Activates/Deactivates the deployment of Loki. Loki is only deployed if Monitoring (Grafana) is also enabled."
}

variable "service_mesh_loki_version" {
  type        = string
  description = "The version of the Loki Helm Chart to be installed."
  default     = ""
}

variable "service_mesh_loki_storage_type" {
  type        = string
  default     = "filesystem"
  description = "Storage backend for Loki. Options: \"filesystem\" (local disk, default) or \"s3\" (external S3-compatible object storage)."
}

variable "service_mesh_loki_deployment_mode" {
  type        = string
  default     = "Monolithic"
  description = "Loki deployment topology. Options: \"Monolithic\" (single-binary, default) or \"SimpleScalable\" (read/write/backend behind a gateway, requires \"s3\" storage)."
}

variable "service_mesh_loki_s3_endpoint" {
  type        = string
  default     = ""
  description = "S3 endpoint host used when service_mesh_loki_storage_type is \"s3\"."
}

variable "service_mesh_loki_s3_region" {
  type        = string
  default     = ""
  description = "S3 region used when service_mesh_loki_storage_type is \"s3\" (may be empty for MinIO / non-AWS)."
}

variable "service_mesh_loki_s3_bucket_chunks" {
  type        = string
  default     = ""
  description = "S3 bucket for Loki chunks."
}

variable "service_mesh_loki_s3_bucket_ruler" {
  type        = string
  default     = ""
  description = "S3 bucket for Loki ruler rules."
}

variable "service_mesh_loki_s3_bucket_admin" {
  type        = string
  default     = ""
  description = "S3 bucket for Loki admin/compactor objects."
}

variable "service_mesh_loki_s3_force_path_style" {
  type        = bool
  default     = true
  description = "Use path-style S3 URLs (true for MinIO / non-AWS, false for real AWS S3)."
}

variable "service_mesh_loki_s3_insecure" {
  type        = bool
  default     = false
  description = "Talk to the S3 endpoint over plain HTTP instead of HTTPS."
}

variable "service_mesh_loki_replicas" {
  type        = number
  default     = 1
  description = "Number of Loki instances. Must be 1 for filesystem storage; values > 1 require S3 storage. In SimpleScalable mode this is the default for the read/write/backend targets unless overridden."
}

variable "service_mesh_loki_read_replicas" {
  type        = number
  default     = null
  description = "Replica count for the SimpleScalable read target. Defaults to service_mesh_loki_replicas when not set."
}

variable "service_mesh_loki_write_replicas" {
  type        = number
  default     = null
  description = "Replica count for the SimpleScalable write target. Defaults to service_mesh_loki_replicas when not set."
}

variable "service_mesh_loki_backend_replicas" {
  type        = number
  default     = null
  description = "Replica count for the SimpleScalable backend target. Defaults to service_mesh_loki_replicas when not set."
}

variable "service_mesh_loki_retention_period" {
  type        = string
  default     = "168h"
  description = "How long ingested logs are kept before deletion (Go duration, e.g. 168h)."
}

variable "service_mesh_istiod_replica_count" {
  description = "The number of replicas that have to be configured for the Istiod services"
  type        = number
  default     = 3
  validation {
    condition     = var.service_mesh_istiod_replica_count > 0
    error_message = "The number of replicas should be greater than 0"
  }
}

variable "service_mesh_monitoring_enabled" {
  type        = bool
  default     = false
  description = "Activates/Deactivates the deployment of Monitoring Services"
}

variable "service_mesh_tracing_sampling" {
  type        = string
  default     = "1.0"
  description = <<EOT
  The sampling rate option can be used to control what percentage of requests get reported to your tracing system. 
  Please refer to the official documentation: https://istio.io/latest/docs/tasks/observability/distributed-tracing/mesh-and-proxy-config/#customizing-trace-sampling"
  EOT
}

variable "service_mesh_external_ip" {
  type        = string
  default     = ""
  description = "The external IP of the ingress gateway, only single IP is supported"
}

variable "service_mesh_ingress_annotations" {
  description = "The annotations to be used for the ingress gateway"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "service_mesh_loadbalancer_sourceranges" {
  description = "The load balancer source ranges to be used for the ingress gateway"
  type        = list(string)
  default     = []
}

variable "prometheus_service_url" {
  description = "The Cluster-internal URL of the Prometheus Instance to be used"
  type        = string
  default     = "http://prometheus:9090"
}

variable "service_mesh_grafana_url" {
  description = "The Cluster-internal URL of the Grafana Instance to be used"
  type        = string
  default     = "http://grafana:3000"
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
