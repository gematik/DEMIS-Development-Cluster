variable "name" {
  type        = string
  description = "Name of the Validation Service deployment"
  validation {
    condition     = length(var.name) > 0
    error_message = "A name must be provided for the Validation Service deployment."
  }
}

variable "deployment_information" {
  description = "Structure holding deployment information for the Helm Charts"
  type = object({
    chart-name          = optional(string) # Optional, uses a different Helm Chart name than the application name
    image-tag           = optional(string) # Optional, uses a different image tag for the deployment
    deployment-strategy = string
    enabled             = bool
    main = object({
      version  = string
      weight   = number
      profiles = optional(list(string))
    })
    canary = optional(object({
      version  = optional(string)
      weight   = optional(string)
      profiles = optional(list(string))
    }), {})
  })
}

variable "external_template_directory" {
  type        = string
  description = "Path to an external directory containing Helm values templates for the Validation Service"
  validation {
    condition     = length(var.external_template_directory) > 0
    error_message = "If provided, the path to the external template directory must not be empty."
  }
}

variable "local_template_directory" {
  type        = string
  description = "Path to a local directory containing Helm values templates for the Validation Service"
  validation {
    condition     = length(var.local_template_directory) > 0
    error_message = "If provided, the path to the local template directory must not be empty."
  }
}

variable "target_namespace" {
  description = "The namespace to deploy the application to"
  type        = string
  validation {
    condition     = length(var.target_namespace) > 0
    error_message = "A target namespace must be provided for the Validation Service deployment."
  }
}

variable "app_template_params" {
  type        = any
  description = "Map of variables to be passed to the application values template for the Validation Service. This allows for dynamic configuration of the application-related Helm values based on user input or other variables."
  default     = {}
}

variable "app_template_file" {
  type        = string
  description = "Path to the application values template file for the Validation Service. If not provided, the default template will be used."
  default     = ""
}

variable "app_values_override" {
  type        = string
  description = "Content of the application values override file for the Validation Service. If not provided, it will be ignored."
  default     = ""
}

variable "istio_template_params" {
  type        = any
  description = "Map of variables to be passed to the Istio values template for the Validation Service. This allows for dynamic configuration of the Istio-related Helm values based on user input or other variables."
  default     = {}
}

variable "istio_template_file" {
  type        = string
  description = "Path to the Istio values template file for the Validation Service. If not provided, the default template will be used."
  default     = ""
}

variable "istio_values_override" {
  type        = string
  description = "Content of the Istio values override file for the Validation Service. If not provided, it will be ignored."
  default     = ""
}

variable "helm_release_settings" {
  type        = map(string)
  description = "Map of common Helm release settings to be applied to the Validation Service deployment. This can include settings such as 'atomic', 'timeout', 'wait', etc., which control the behavior of the Helm release process."
}

variable "profile_provisioning_mode" {
  description = "Provisioning mode for the FHIR Profiles services. Allowed values are: dedicated, distributed, combined"
  type        = string
  nullable    = false
  validation {
    condition     = contains(["dedicated", "distributed", "combined"], var.profile_provisioning_mode)
    error_message = "The provisioning mode must be one of the following: dedicated, distributed, combined"
  }
}

variable "package_type" {
  description = "Profile types for the validation services. Allowed values are: fhir-profile-snapshots, igs-profile-snapshots, ars-profile-snapshots, are-profile-snapshots"
  type        = string
}

# Feature Flags
variable "feature_flags" {
  type        = map(map(bool))
  description = "Defines a list of feature flags to be bound in services"
  default     = {}
}

# Operational Flags
variable "config_options" {
  type        = map(map(string))
  description = "Defines a list of ops flags to be bound in services"
  default     = {}
}

variable "resource_definitions" {
  description = "Defines a list of definition of resources that belong to a service"
  type = map(object({
    resource_block = optional(string)
    istio_proxy_resources = optional(object({
      limits   = optional(map(string))
      requests = optional(map(string))
    }))
    replicas = number
  }))
  default = {}
}
variable "timeout_retries" {
  description = "Defines retry and timeout override configurations per service. Each definition must include a service name and can optionally include timeout and retry settings."
  type        = map(any)
  default     = {}
}
