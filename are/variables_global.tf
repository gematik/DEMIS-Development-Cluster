####################
# Global Settings
####################

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file for the cluster"
  type        = string
  default     = ""
  nullable    = false
  validation {
    condition     = length(var.kubeconfig_path) > 0 ? fileexists(var.kubeconfig_path) : true
    error_message = "The provided kubeconfig file does not exist"
  }
}

variable "target_namespace" {
  type        = string
  description = "The Namespace to use for deployment"
  default     = "are"
  validation {
    condition     = length(var.target_namespace) > 0
    error_message = "Invalid Namespace provided"
  }
}

# New variable for overriding the stage name
variable "override_stage_name" {
  description = "Override the automatically detected stage name (optional)"
  type        = string
  default     = ""
}

# Helm-Specific
variable "helm_repository" {
  type        = string
  description = "The Helm Repository where is stored the Helm Chart"
  validation {
    condition     = startswith(var.helm_repository, "https://") || startswith(var.helm_repository, "oci://")
    error_message = "Invalid Helm Repository provided"
  }
}

variable "docker_registry" {
  type        = string
  description = "The Docker Registry to use for pulling Images"
  validation {
    condition     = strcontains(var.docker_registry, "docker.io/gematik1") || startswith(var.docker_registry, "europe-west3-docker.pkg.dev/gematik-all-infra-prod/demis")
    error_message = "Unsupported Docker Registry provided"
  }
}

variable "reset_values" {
  type        = bool
  description = "Reset the values to the ones built into the chart. This will override any custom values and reuse_values settings."
  default     = false
}

# only used for remote clusters deployment with GCP KMS state encryption
variable "kms_encryption_key" {
  description = "The GCP KMS encryption key for OpenTofu state encryption"
  type        = string
  default     = ""
  validation {
    condition     = length(var.kms_encryption_key) > 0 ? startswith(var.kms_encryption_key, "projects/") : true
    error_message = "Invalid KMS encryption key format, must start with 'projects/...'"
  }
}

# used in environments with different parallel versions of DEMIS Services
variable "context_path" {
  description = "The context path for reaching the DEMIS Services externally"
  type        = string
  default     = ""
}

# Resource Quota for the target Namespace
variable "namespace_resource_quota" {
  type = object({
    limits_cpu      = optional(string)
    limits_memory   = optional(string)
    requests_cpu    = optional(string)
    requests_memory = optional(string)
  })
  description = "Resource quota configuration for the target Namespace. Set to null to skip quota creation."
  default     = null
}

variable "deployment_timeout" {
  type        = number
  description = "Timeout for the deployment in minutes"
  default     = 600
}

# tflint-ignore: terraform_unused_declarations
variable "project_feature_flags" {
  type        = map(bool)
  description = "Map of feature flags to enable or disable specific features in the DEMIS deployment. The keys are the names of the feature flags, and the values are booleans indicating whether the feature is enabled (true) or disabled (false)."
  default     = {}
}
