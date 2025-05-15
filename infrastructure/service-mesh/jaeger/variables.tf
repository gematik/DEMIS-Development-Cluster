variable "target_namespace" {
  description = "Namespace where to install the services"
  type        = string
  default     = "istio-system"
}

variable "jaeger_version" {
  description = "The version of Jaeger to be installed"
  type        = string
  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.jaeger_version))
    error_message = "The Jaeger version must be provided in a valid Semantic Version format (e.g., 1.2.3)"
  }
}

variable "jaeger_digest" {
  description = "The digest of the Jaeger Service to be used"
  type        = string
  validation {
    condition     = can(regex("^sha256:[a-f0-9]{64}$", var.jaeger_digest))
    error_message = "The Jaeger digest must be a valid SHA256 digest"
  }
}

variable "jaeger_max_traces" {
  description = "The maximum number of traces to be kept"
  type        = number
  default     = "50000"
}
