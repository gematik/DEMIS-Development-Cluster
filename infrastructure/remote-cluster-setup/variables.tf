variable "target_namespace" {
  type        = string
  description = "The target namespace to be used"
  default     = "kube-system"
  validation {
    condition     = length(var.target_namespace) > 0
    error_message = "The target namespace must not be empty"
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
