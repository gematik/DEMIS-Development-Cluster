variable "local_deployment" {
  description = "Defines if the components (Grafana, Prometheus) have to be installed locally."
  type        = bool
  default     = false
}

variable "local_node_ports_istio" {
  description = "Defines the node ports to use with the local cluster (kind)"
  type = list(object({
    port       = number
    targetPort = number
    name       = string
    protocol   = string
    nodePort   = string
  }))
  default = [{
    name       = "status-port"
    protocol   = "TCP"
    port       = 15021
    targetPort = 15021
    nodePort   = 30002
    },
    {
      name       = "http2"
      protocol   = "TCP"
      port       = 80
      targetPort = 80
      nodePort   = 30000
    },
    {
      name       = "https"
      protocol   = "TCP"
      port       = 443
      targetPort = 443
      nodePort   = 30001
  }]
}

variable "namespace" {
  description = "Namespace where to install the services"
  type        = string
  default     = "istio-system"
}

variable "istio_version" {
  type        = string
  default     = "1.23.0"
  description = "The version of the Istio Helm Chart to be installed."
}

variable "istio_replica_count" {
  description = "The number of replicas that have to be configured for the Istio services"
  type        = number
  default     = 3
}

variable "kiali_enabled" {
  description = "Defines if Kiali has to be deployed"
  type        = bool
  default     = true
}

variable "kiali_version" {
  description = "The version of the Kiali Helm Chart to be installed"
  type        = string
  default     = "2.5.0"
}

variable "prometheus_enabled" {
  description = "Defines if Prometheus has to be deployed"
  type        = bool
  default     = false
}

variable "prometheus_version" {
  description = "The version of the Prometheus Service to be installed"
  type        = string
  default     = "27.3.0"
}

variable "jaeger_enabled" {
  description = "Defines if Jaeger has to be deployed"
  type        = bool
  default     = true
}

variable "jaeger_version" {
  description = "The version of the Jaeger Service to be installed"
  type        = string
  default     = "1.66.0"
}

variable "jaeger_digest" {
  description = "The digest of the Jaeger Service to be used"
  type        = string
  default     = "sha256:9864182b4e01350fcc64631bdba5f4085f87daae9d477a04c25d9cb362e787a9"
}

variable "grafana_enabled" {
  description = "Defines if Grafana has to be deployed"
  type        = bool
  default     = false
}

variable "grafana_version" {
  description = "The version of the Grafana Service to be installed"
  type        = string
  default     = "11.5.1"
}

variable "grafana_digest" {
  description = "The digest of the Grafana Service to be used"
  type        = string
  default     = "sha256:5781759b3d27734d4d548fcbaf60b1180dbf4290e708f01f292faa6ae764c5e6"
}

variable "loki_enabled" {
  description = "Defines if Loki has to be deployed. Loki is only deployed if Grafana is also enabled."
  type        = bool
  default     = false
}

variable "loki_version" {
  description = "The version of the Loki Service to be installed"
  type        = string
  default     = "18.5.1"
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

variable "loki_s3_access_key_id" {
  description = "The S3 access key id used when loki_storage_type is s3."
  type        = string
  default     = ""
  sensitive   = true
}

variable "loki_s3_secret_access_key" {
  description = "The S3 secret access key used when loki_storage_type is s3."
  type        = string
  default     = ""
  sensitive   = true
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

variable "trace_sampling" {
  description = "The sampling rate option can be used to control what percentage of requests get reported to your tracing system. (https://istio.io/latest/docs/tasks/observability/distributed-tracing/mesh-and-proxy-config/#customizing-trace-sampling)"
  type        = string
  default     = "1.0"
}

variable "external_ip" {
  description = "The external IP of the ingress gateway, only single IP is supported"
  type        = string
  default     = ""
}

variable "ingress_annotations" {
  description = "The annotations to be used for the ingress gateway"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "loadbalancer_sourceranges" {
  description = "The load balancer source ranges to be used for the ingress gateway"
  type        = list(string)
  default     = []
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
