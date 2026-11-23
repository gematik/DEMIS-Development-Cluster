variable "target_namespace" {
  description = "Namespace where to install the services"
  type        = string
  default     = "observability"
}

variable "kiali_helm_repository" {
  description = "The Helm Repository to download the Kiali Chart"
  type        = string
  default     = "https://kiali.org/helm-charts"
  nullable    = false
  validation {
    condition     = can(regex("^(https?|file|oci)://.*$", var.kiali_helm_repository)) || can(regex("^[a-z0-9][a-z0-9._-]*$", var.kiali_helm_repository))
    error_message = "The Kiali Helm Repository must be a valid URL or a repository name"
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
  description = "Cluster-internal URL of Prometheus, null leaves it to the Kiali default"
  type        = string
  default     = null
}

variable "tracing_service_url" {
  description = "Cluster-internal gRPC query URL of Jaeger, null switches the tracing integration off"
  type        = string
  default     = null
}

variable "tracing_service_port" {
  description = "gRPC query port of Jaeger"
  type        = string
  default     = "16685"
}

variable "grafana_service_url" {
  description = "Cluster-internal URL of Grafana, null switches the Grafana integration off"
  type        = string
  default     = null
}

variable "grafana_public_url" {
  description = "Public URL of Grafana (the link in Kiali)"
  type        = string
  default     = null
}

variable "resource_definitions" {
  description = "Per workload of the module (output of the resources module): replicas, resource block (YAML) and Istio proxy resources; null or missing keeps the defaults"
  type = map(object({
    replicas       = optional(number)
    resource_block = optional(string)
    istio_proxy_resources = optional(object({
      limits   = optional(map(string), {})
      requests = optional(map(string), {})
    }))
  }))
  default = {}
}
