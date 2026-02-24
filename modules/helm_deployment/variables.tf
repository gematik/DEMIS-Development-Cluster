# Common
variable "namespace" {
  type        = string
  description = "The Namespace where to install the Helm Chart"
  validation {
    condition     = length(var.namespace) > 0
    error_message = "Namespace is required"
  }
}

# Helm Deployment Settings
variable "helm_settings" {
  type = object({
    chart_image_tag_property_name = string                            # the Helm Chart Property Name where the Image Tag is set (e.g. "image.tag")
    helm_repository               = string                            # the Helm Repository URL
    helm_repository_username      = optional(string)                  # optional (required for private registries), the Helm Repository Username
    helm_repository_password      = optional(string)                  # optional (required for private registries), the Helm Repository Password
    istio_routing_chart_version   = optional(string)                  # optional, the Version of the Istio Routing Helm Chart to be installed
    deployment_timeout            = optional(number)                  # optional, the Timeout for creating Helm Release
    istio_routing_chart_name      = optional(string, "istio-routing") # optional, the name of the Istio Routing Helm Chart
    reset_values                  = optional(bool, false)             # optional, whether to reset values to the ones built into the chart
  })
  sensitive   = true
  description = "Helm Release settings as Object."
  validation {
    condition     = length(var.helm_settings.chart_image_tag_property_name) > 0 && (startswith(var.helm_settings.helm_repository, "https://") || startswith(var.helm_settings.helm_repository, "oci://")) && var.helm_settings.deployment_timeout != null ? var.helm_settings.deployment_timeout > 0 : true
    error_message = "Invalid Helm Settings provided. Please ensure that the Helm Chart Image Tag Property Name is set, the Helm Repository URL is valid and the Deployment Timeout is greater than 0."
  }
}

# The name of the Helm Chart for the Application
variable "application_name" {
  type        = string
  description = "The name of the application. This can also correspond to the Helm Chart name."
  validation {
    condition     = length(var.application_name) > 0
    error_message = "The name of the application is required"
  }
}

# Deployment specific Information provided from the Stage "active-versions.yaml" file
variable "deployment_information" {
  type = object({
    chart-name          = optional(string) # Optional, uses a different Helm Chart name than the application name
    image-tag           = optional(string) # Optional, uses a different image tag for the deployment
    deployment-strategy = string
    enabled             = bool
    main = object({
      version = string
      weight  = number
    })
    canary = optional(object({
      version = optional(string)
      weight  = optional(string)
    }), {})
  })
  description = "Deployment information for managing the main and optional canary version of the application"
  validation {
    condition     = contains(["canary", "replace", "update", "rolling"], var.deployment_information.deployment-strategy)
    error_message = "The deployment strategy must be 'canary', 'replace', 'update' or 'rolling'"
  }
}

variable "application_values" {
  type        = string
  description = "Custom values in YAML format to override the default configuration for the application Helm Chart"
  default     = ""
}

variable "istio_values" {
  type        = string
  description = "Custom values in YAML format to override the configuration for the Istio Helm Chart"
  default     = ""
}
