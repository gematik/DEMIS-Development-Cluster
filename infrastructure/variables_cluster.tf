#########################
# (Remote) Cluster Settings
#########################

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file for the cluster"
  type        = string
  default     = null
  nullable    = true
}

variable "stage_name" {
  description = "The name of the stage"
  type        = string
  validation {
    condition     = length(var.stage_name) > 0
    error_message = "The stage name must not be empty"
  }
}

variable "cluster_region" {
  description = "The name of the region where the cluster is deployed"
  type        = string
  validation {
    condition     = length(var.cluster_region) > 0
    error_message = "The cluster region must not be empty"
  }
}

variable "service_account_name" {
  type        = string
  description = "The Service Account name to be configured"
  default     = "api-service-account"
  validation {
    condition     = length(var.service_account_name) > 0
    error_message = "The Service Account name must not be empty"
  }
}

variable "cluster_role_name" {
  type        = string
  description = "Defines the Cluster Role Name to be configured"
  default     = "api-cluster-role"
  validation {
    condition     = length(var.cluster_role_name) > 0
    error_message = "The Cluster Role Name must not be empty"
  }
}

# only used for remote clusters deployment with GCP KMS state encryption
variable "kms_encryption_key" {
  description = "The GCP KMS encryption key for OpenTofu state encryption"
  type        = string
  default     = ""
  validation {
    condition     = length(var.kms_encryption_key) == 0 || startswith(var.kms_encryption_key, "projects/")
    error_message = "Invalid KMS encryption key format, must start with 'projects/...'"
  }
}