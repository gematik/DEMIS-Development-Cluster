variable "target_namespace" {
  description = "Namespace where to install the services"
  type        = string
  default     = "istio-system"
}

variable "prometheus_helm_repository" {
  description = "The Helm Repository to download the Prometheus Chart"
  type        = string
  default     = "https://prometheus-community.github.io/helm-charts"
  validation {
    condition     = can(regex("^(https?|file|oci)://.*$", var.prometheus_helm_repository))
    error_message = "The Prometheus Helm Repository must be a valid URL"
  }
}

variable "prometheus_version" {
  description = "The version of Prometheus to be installed"
  type        = string
  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.prometheus_version))
    error_message = "The Prometheus version must be provided in a valid Semantic Version format (e.g., 1.2.3)"
  }
}
