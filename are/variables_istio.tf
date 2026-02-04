#########################
# Istio Settings
#########################

variable "istio_enabled" {
  type        = bool
  description = "Defines if Istio Settings are enabled for the given target namespace"
  default     = true
}

variable "timeout_retry_overrides" {
  description = "Defines retry and timeout configurations per service. Each definition must include a service name and can optionally include timeout and retry settings."
  type = list(object({
    service = string
    timeout = optional(string)
    retries = optional(object({
      enable        = optional(bool)
      attempts      = optional(number)
      perTryTimeout = optional(string)
      retryOn       = optional(string)
    }))
  }))
  default = []

  validation {
    condition     = length(var.timeout_retry_overrides) > 0 ? alltrue([for conf in var.timeout_retry_overrides : length(conf.service) > 0]) : true
    error_message = "Service name must not be empty"
  }
}
