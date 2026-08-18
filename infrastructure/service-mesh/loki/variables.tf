variable "target_namespace" {
  description = "Namespace where to install the services"
  type        = string
  default     = "istio-system"
}

variable "loki_helm_repository" {
  description = "The Helm Repository to download the Loki Chart"
  type        = string
  default     = "oci://ghcr.io/grafana-community/helm-charts"
  validation {
    condition     = can(regex("^(https?|file|oci)://.*$", var.loki_helm_repository))
    error_message = "The Loki Helm Repository must be a valid URL"
  }
}

variable "loki_version" {
  description = "The version of Loki to be installed"
  type        = string
  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.loki_version))
    error_message = "The Loki version must be provided in a valid Semantic Version format (e.g., 1.2.3)"
  }
}

variable "loki_deployment_mode" {
  description = "Loki chart deployment topology. Options: \"Monolithic\" (all components in one single-binary process; works with filesystem storage) or \"SimpleScalable\" (separate read/write/backend targets behind a gateway; requires S3 storage)."
  type        = string
  default     = "Monolithic"
  validation {
    condition     = contains(["Monolithic", "SimpleScalable"], var.loki_deployment_mode)
    error_message = "The loki_deployment_mode must be either \"Monolithic\" or \"SimpleScalable\"."
  }
}

variable "loki_storage_type" {
  description = "Storage backend for Loki chunks/indexes. Options: \"filesystem\" (local disk, default) or \"s3\" (external S3-compatible object storage, required for more than one replica)."
  type        = string
  default     = "filesystem"
  validation {
    condition     = contains(["filesystem", "s3"], var.loki_storage_type)
    error_message = "The loki_storage_type must be either \"filesystem\" or \"s3\"."
  }
}

variable "loki_s3_endpoint" {
  description = "S3 endpoint host used when loki_storage_type is \"s3\" (e.g. \"s3.eu-central-1.amazonaws.com\" or a MinIO host)."
  type        = string
  default     = ""
}

variable "loki_s3_region" {
  description = "S3 region used when loki_storage_type is \"s3\" (may be empty for MinIO / non-AWS endpoints)."
  type        = string
  default     = ""
}

variable "loki_s3_bucket_chunks" {
  description = "S3 bucket for Loki chunks (used when loki_storage_type is \"s3\")."
  type        = string
  default     = ""
}

variable "loki_s3_bucket_ruler" {
  description = "S3 bucket for Loki ruler rules (used when loki_storage_type is \"s3\")."
  type        = string
  default     = ""
}

variable "loki_s3_bucket_admin" {
  description = "S3 bucket for Loki admin/compactor objects (used when loki_storage_type is \"s3\")."
  type        = string
  default     = ""
}

variable "loki_s3_force_path_style" {
  description = "Use path-style S3 URLs. true for MinIO / most non-AWS endpoints, false for real AWS S3."
  type        = bool
  default     = true
}

variable "loki_s3_insecure" {
  description = "Talk to the S3 endpoint over plain HTTP instead of HTTPS."
  type        = bool
  default     = false
}

variable "loki_s3_access_key_id" {
  description = "The S3 access key id used when loki_storage_type is \"s3\". Leave empty to rely on an IAM role / instance profile."
  type        = string
  default     = ""
  sensitive   = true
}

variable "loki_s3_secret_access_key" {
  description = "The S3 secret access key used when loki_storage_type is \"s3\". Leave empty to rely on an IAM role / instance profile."
  type        = string
  default     = ""
  sensitive   = true
}

variable "loki_replicas" {
  description = "Number of Loki instances for the monolithic target. Must be 1 for filesystem storage; values > 1 require S3 storage. In SimpleScalable mode this is the default replica count for the read/write/backend targets unless overridden."
  type        = number
  default     = 1
  validation {
    condition     = var.loki_replicas >= 1
    error_message = "The loki_replicas value must be at least 1."
  }
}

variable "loki_read_replicas" {
  description = "Replica count for the SimpleScalable read target (queriers / query-frontend). Defaults to loki_replicas when not set. Ignored in Monolithic mode."
  type        = number
  default     = null
  validation {
    condition     = var.loki_read_replicas == null || try(var.loki_read_replicas >= 1, false)
    error_message = "The loki_read_replicas value must be at least 1."
  }
}

variable "loki_write_replicas" {
  description = "Replica count for the SimpleScalable write target (distributors / ingesters). Defaults to loki_replicas when not set. Ignored in Monolithic mode."
  type        = number
  default     = null
  validation {
    condition     = var.loki_write_replicas == null || try(var.loki_write_replicas >= 1, false)
    error_message = "The loki_write_replicas value must be at least 1."
  }
}

variable "loki_backend_replicas" {
  description = "Replica count for the SimpleScalable backend target (compactor / ruler / index-gateway). Defaults to loki_replicas when not set. Ignored in Monolithic mode."
  type        = number
  default     = null
  validation {
    condition     = var.loki_backend_replicas == null || try(var.loki_backend_replicas >= 1, false)
    error_message = "The loki_backend_replicas value must be at least 1."
  }
}

variable "loki_retention_period" {
  description = "How long ingested logs are kept before the compactor deletes them (Go duration, e.g. 24h, 168h, 720h)."
  type        = string
  default     = "168h"
  validation {
    condition     = can(regex("^[0-9]+[smhd]$", var.loki_retention_period))
    error_message = "The loki_retention_period must be a valid Go duration (e.g. 24h, 168h)."
  }
}
