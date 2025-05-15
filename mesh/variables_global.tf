
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
