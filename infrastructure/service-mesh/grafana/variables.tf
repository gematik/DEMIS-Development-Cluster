variable "target_namespace" {
  description = "Namespace where to install the services"
  type        = string
  default     = "istio-system"
}

variable "grafana_version" {
  description = "The version of the Grafana Service to be installed"
  type        = string
  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.grafana_version))
    error_message = "The Grafana version must be provided in a valid Semantic Version format (e.g., 1.2.3)"
  }
}

variable "grafana_digest" {
  description = "The digest of the Grafana Service to be used"
  type        = string
  # Validate the Grafana digest only if it is set
  validation {
    condition     = can(regex("^sha256:[a-f0-9]{64}$", var.grafana_digest))
    error_message = "The Grafana digest must be a valid SHA256 digest"
  }
}

variable "istio_version" {
  description = "The version of the Istio Services for downloading the correct dashboards"
  type        = string
  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.istio_version))
    error_message = "The Istio version must be provided in a valid Semantic Version format (e.g., 1.2.3)"
  }
}
