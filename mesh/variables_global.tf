
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
  description = "The Namespace to use for the deployment of mesh components"
  default     = "mesh"
  validation {
    condition     = length(var.target_namespace) > 0
    error_message = "Invalid Namespace provided"
  }
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

variable "helm_repository_source" {
  type        = string
  description = "Where Helm Charts are resolved from: 'url' uses helm_repository with the credentials from credentials.tfvars, 'local' uses the repository name helm_repository_name from the Helm repositories.yaml (credentials and index cache are taken from there)"
  default     = "url"
  validation {
    condition     = contains(["url", "local"], var.helm_repository_source)
    error_message = "helm_repository_source must be either 'url' or 'local'"
  }
}

variable "helm_repository_name" {
  type        = string
  description = "The repository name in the Helm repositories.yaml, used if helm_repository_source is 'local'"
  default     = "demis"
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
