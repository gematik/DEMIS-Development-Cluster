# Definition of Resources in terms of Limits, Requests and Replicas for each service, as list
variable "resource_definitions" {
  description = "Defines a list of definition of resources that belong to a service"
  type = list(object({
    service  = string
    replicas = number
    resources = optional(object({
      limits = optional(object({
        cpu    = optional(string)
        memory = optional(string)
      }))
      requests = optional(object({
        cpu    = optional(string)
        memory = optional(string)
      }))
    }))
  }))
  default = []

  validation {
    condition     = length(var.resource_definitions) > 0 ? alltrue([for rd in var.resource_definitions : length(rd.service) > 0 && rd.replicas >= 0]) : true
    error_message = "Service name must not be empty, Replicas must be greater than or equal to 0"
  }
}
