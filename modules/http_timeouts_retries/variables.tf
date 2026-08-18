variable "service_names" {
  description = "List of all deployed service names (typically keys(deployment_information)). Every service in this list that has no explicit no_retries_services, custom_timeout_retry or timeout_retry_overrides configuration receives the built-in common default (timeout 5s, 1 attempt, perTryTimeout 5s)."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for name in var.service_names : length(name) > 0])
    error_message = "Service name must not be empty"
  }
}

variable "no_retries_services" {
  description = "List of service names that should receive the built-in no-retries default (0 attempts). Explicit custom_timeout_retry and timeout_retry_overrides take precedence."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for name in var.no_retries_services : length(name) > 0])
    error_message = "Service name must not be empty"
  }
}

# Definition of Resources in terms of Limits, Requests and Replicas for each service, as list
variable "custom_timeout_retry" {
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
    condition     = length(var.custom_timeout_retry) > 0 ? alltrue([for conf in var.custom_timeout_retry : length(conf.service) > 0]) : true
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
