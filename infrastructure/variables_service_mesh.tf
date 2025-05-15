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