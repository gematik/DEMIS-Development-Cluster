variable "stage_name" {
  description = "The name of the stage"
  type        = string
  validation {
    condition     = length(var.stage_name) > 0
    error_message = "The stage name must not be empty"
  }
}

variable "target_namespace" {
  type        = string
  description = "The Namespace to use for deployment"
  default     = "kc-management"
  validation {
    condition     = length(var.target_namespace) > 0
    error_message = "Invalid Namespace provided: ${var.target_namespace}"
  }
}

variable "local_cluster" {
  type        = bool
  default     = true
  description = "Defines if the current setup is for a local cluster (using KIND)"
}

variable "insecure_connection" {
  type        = bool
  default     = false
  description = "Whether TLS certificate verification should be skipped for HTTPS connections"
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

variable "is_production" {
  type        = bool
  default     = true
  description = "Whether the environment is a production environment. Used to prevent destroying critical realms."
}

variable "project_feature_flags" {
  type        = map(bool)
  description = "Map of feature flags to enable or disable specific features in the keycloak deployment. The keys are the names of the feature flags, and the values are booleans indicating whether the feature is enabled (true) or disabled (false)."
  default     = {}
}