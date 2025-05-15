variable "name" {
  type        = string
  description = "The name of the Namespace that should be created"
  validation {
    condition     = length(var.name) > 0
    error_message = "You must provide a valid name for the Namespace."
  }
}

variable "labels" {
  type        = map(string)
  description = "The labels to apply to the Namespace"
  default     = {}
}

variable "annotations" {
  type        = map(string)
  description = "The annotations to apply to the Namespace"
  default     = {}
}

variable "enable_istio_injection" {
  type        = bool
  description = "Enable Istio Sidecar Injection for the Namespace"
  default     = false
}