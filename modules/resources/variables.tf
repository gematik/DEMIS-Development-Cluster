# Definition of Resources in terms of Limits, Requests and Replicas for each service, as list
variable "resource_definitions" {
  description = <<EOT
  Defines a list of definition of resources that belong to a service

  service - is required with min length 1
  replicas - is required
  resources - could be set by properties named limits and requests
  istio_proxy_resources- could be set by properties named limits and requests
  limits - could be set by properties named cpu and memory
  requests - could set by properties named cpu and memory
EOT
  type = list(object({
    service  = string
    replicas = number
    resources = optional(object({
      limits   = optional(map(string))
      requests = optional(map(string))
    }))
    istio_proxy_resources = optional(object({
      limits   = optional(map(string))
      requests = optional(map(string))
    }))
  }))
  default = []

  validation {
    condition     = length(var.resource_definitions) > 0 ? alltrue([for rd in var.resource_definitions : (length(rd.service) > 0 && rd.replicas >= 0)]) : true
    error_message = "Service name must not be empty, Replicas must be greater than or equal to 0"
  }

  validation {
    condition = alltrue([for rd in var.resource_definitions :
      (try(rd.resources, null) == null ? true : alltrue([
        for key in keys(rd.resources) : contains(["limits", "requests"], key)
      ]))
    ])
    error_message = "The 'resources' object can only contain 'limits' and 'requests' properties. No additional properties are allowed."
  }

  validation {
    condition = alltrue([for rd in var.resource_definitions :
      (try(rd.resources.limits, null) == null ? true : alltrue([
        for key in keys(rd.resources.limits) : contains(["cpu", "memory"], key)
      ]))
    ])
    error_message = "The 'resources.limits' object can only contain 'cpu' and 'memory' properties. No additional properties are allowed."
  }

  validation {
    condition = alltrue([for rd in var.resource_definitions :
      (try(rd.resources.requests, null) == null ? true : alltrue([
        for key in keys(rd.resources.requests) : contains(["cpu", "memory"], key)
      ]))
    ])
    error_message = "The 'resources.requests' object can only contain 'cpu' and 'memory' properties. No additional properties are allowed."
  }

  validation {
    condition = alltrue([for rd in var.resource_definitions :
      (try(rd.istio_proxy_resources, null) == null ? true : alltrue([
        for key in keys(rd.istio_proxy_resources) : contains(["limits", "requests"], key)
      ]))
    ])
    error_message = "The 'istio_proxy_resources' object can only contain 'limits' and 'requests' properties. No additional properties are allowed."
  }

  validation {
    condition = alltrue([for rd in var.resource_definitions :
      (try(rd.istio_proxy_resources.limits, null) == null ? true : alltrue([
        for key in keys(rd.istio_proxy_resources.limits) : contains(["cpu", "memory"], key)
      ]))
    ])
    error_message = "The 'istio_proxy_resources.limits' object can only contain 'cpu' and 'memory' properties. No additional properties are allowed."
  }

  validation {
    condition = alltrue([for rd in var.resource_definitions :
      (try(rd.istio_proxy_resources.requests, null) == null ? true : alltrue([
        for key in keys(rd.istio_proxy_resources.requests) : contains(["cpu", "memory"], key)
      ]))
    ])
    error_message = "The 'istio_proxy_resources.requests' object can only contain 'cpu' and 'memory' properties. No additional properties are allowed."
  }

  validation {
    condition = alltrue([for rd in var.resource_definitions :
      alltrue([
        for cpu in compact([
          try(rd.resources.limits.cpu, null),
          try(rd.resources.requests.cpu, null),
          try(rd.istio_proxy_resources.limits.cpu, null),
          try(rd.istio_proxy_resources.requests.cpu, null)
        ]) : can(regex("^[0-9]+(\\.[0-9]+)?m?$", cpu))
      ])
    ])
    error_message = "CPU values must be valid Kubernetes format (e.g., '100m', '1', '0.5')"
  }

  validation {
    condition = alltrue([for rd in var.resource_definitions :
      alltrue([
        for mem in compact([
          try(rd.resources.limits.memory, null),
          try(rd.resources.requests.memory, null),
          try(rd.istio_proxy_resources.limits.memory, null),
          try(rd.istio_proxy_resources.requests.memory, null)
        ]) : can(regex("^[0-9]+(\\.[0-9]+)?([EPTGMK]i?)?$", mem))
      ])
    ])
    error_message = "Memory values must be valid Kubernetes format (e.g., '256Mi', '1Gi', '512M')"
  }
}

variable "services" {
  description = "List of available services"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.services) > 0 ? alltrue([for s in var.services : (length(s) > 0)]) : true
    error_message = "Service name must not be empty"
  }
}
