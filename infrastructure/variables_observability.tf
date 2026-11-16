#########################
# Observability Module (deployed separately)
#########################

variable "observability_namespace" {
  type        = string
  default     = "observability"
  description = "Namespace of the observability module; with FEATURE_FLAG_OBSERVABILITY_NAMESPACE_ENABLED the tracing provider of istiod points to its Jaeger"
  validation {
    condition     = length(var.observability_namespace) > 0
    error_message = "The Observability namespace must not be empty"
  }
}
