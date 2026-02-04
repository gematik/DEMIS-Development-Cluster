# Definition of Resources in terms of Limits, Requests and Replicas for each service, as list
variable "timeout_retry_defaults" {
  description = "Defines retry and timeout default configurations per service. Each definition must include a service name and can optionally include timeout and retry settings."
  type = list(object({
    service = string
    timeout = optional(string)
    retries = optional(object({
      attempts      = optional(number)
      perTryTimeout = optional(string)
      retryOn       = optional(string)
    }))
  }))
  default = []

  validation {
    condition     = length(var.timeout_retry_defaults) > 0 ? alltrue([for conf in var.timeout_retry_defaults : length(conf.service) > 0]) : true
    error_message = "Service name must not be empty"
  }
}

variable "timeout_retry_overrides" {
  description = "Defines retry and timeout override configurations per service. Each definition must include a service name and can optionally include timeout and retry settings."
  type = list(object({
    service = string
    timeout = optional(string)
    retries = optional(object({
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
