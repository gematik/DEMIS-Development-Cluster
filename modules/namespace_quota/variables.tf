variable "namespace" {
  type        = string
  description = "The name of the Namespace to apply the ResourceQuota to"
  validation {
    condition     = length(var.namespace) > 0
    error_message = "You must provide a valid Namespace name."
  }
}

variable "resource_quota" {
  type = object({
    limits_cpu      = optional(string)
    limits_memory   = optional(string)
    requests_cpu    = optional(string)
    requests_memory = optional(string)
  })
  description = "Resource quota configuration for the Namespace. Set to null to skip quota creation."
  default     = null
}
