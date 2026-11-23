#########################
# Istio Settings
#########################

variable "timeout_retry_overrides" {
  description = "Timeout and retry overrides per workload of the namespace (timeout_retry_overrides.tfvars), merged over the built-in defaults. Services: object-storage-service."
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
    condition     = alltrue([for conf in var.timeout_retry_overrides : contains(["object-storage-service"], conf.service)])
    error_message = "Timeouts and retries can only be set for the object-storage-service, the only HTTP service with a VirtualService (Loki uses the Istio defaults, postgres and pgbouncer are TCP, the audit-log-service is called by ext_proc without route)."
  }
}
