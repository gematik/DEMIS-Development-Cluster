variable "target_namespace" {
  description = "Namespace where to install the services"
  type        = string
  default     = "istio-system"
}

variable "kiali_helm_repository" {
  description = "The Helm Repository to download the Kiali Chart"
  type        = string
  default     = "https://kiali.org/helm-charts"
  validation {
    condition     = can(regex("^(https?|file|oci)://.*$", var.kiali_helm_repository))
    error_message = "The Kiali Helm Repository must be a valid URL"
  }
}

variable "kiali_version" {
  description = "The version of Kiali to be installed"
  type        = string
  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.kiali_version))
    error_message = "The Kiali version must be provided in a valid Semantic Version format (e.g., 1.2.3)"
  }
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
